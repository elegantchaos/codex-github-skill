#!/usr/bin/env swift

import Foundation

struct CLIError: Error, CustomStringConvertible {
  let message: String
  var description: String { message }
}

struct Config {
  var newTag: String
  var target: String = "main"
  var previousTag: String?
  var outputPath: String
  var repoPath: String = FileManager.default.currentDirectoryPath
  var includeMerges: Bool = false
}

func printUsage() {
  let usage = """
  Usage:
    generate_release_notes.swift --new-tag <tag> --output <file> [options]

  Required:
    --new-tag <tag>         New release tag (example: v2.1.0)
    --output <file>         Output markdown file path

  Options:
    --target <ref>          Git ref to release from (default: main)
    --previous-tag <tag>    Explicit previous tag (auto-detected if omitted)
    --repo <path>           Repository path (default: current directory)
    --include-merges        Include merge commits in notes
    --help                  Show this help
  """
  print(usage)
}

func run(_ executable: String, _ arguments: [String], cwd: String) throws -> (Int32, String, String) {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: executable)
  process.arguments = arguments
  process.currentDirectoryURL = URL(fileURLWithPath: cwd)

  let stdout = Pipe()
  let stderr = Pipe()
  process.standardOutput = stdout
  process.standardError = stderr

  try process.run()
  process.waitUntilExit()

  let outData = stdout.fileHandleForReading.readDataToEndOfFile()
  let errData = stderr.fileHandleForReading.readDataToEndOfFile()
  let out = String(data: outData, encoding: .utf8) ?? ""
  let err = String(data: errData, encoding: .utf8) ?? ""
  return (process.terminationStatus, out, err)
}

func parseArgs(_ args: [String]) throws -> Config {
  var i = 0
  var newTag: String?
  var target = "main"
  var previousTag: String?
  var outputPath: String?
  var repoPath = FileManager.default.currentDirectoryPath
  var includeMerges = false

  while i < args.count {
    switch args[i] {
    case "--new-tag":
      i += 1
      guard i < args.count else { throw CLIError(message: "Missing value for --new-tag") }
      newTag = args[i]

    case "--target":
      i += 1
      guard i < args.count else { throw CLIError(message: "Missing value for --target") }
      target = args[i]

    case "--previous-tag":
      i += 1
      guard i < args.count else { throw CLIError(message: "Missing value for --previous-tag") }
      previousTag = args[i]

    case "--output":
      i += 1
      guard i < args.count else { throw CLIError(message: "Missing value for --output") }
      outputPath = args[i]

    case "--repo":
      i += 1
      guard i < args.count else { throw CLIError(message: "Missing value for --repo") }
      repoPath = args[i]

    case "--include-merges":
      includeMerges = true

    case "--help", "-h":
      printUsage()
      exit(0)

    default:
      throw CLIError(message: "Unknown argument: \(args[i])")
    }

    i += 1
  }

  guard let tag = newTag, !tag.isEmpty else {
    throw CLIError(message: "--new-tag is required")
  }
  guard let output = outputPath, !output.isEmpty else {
    throw CLIError(message: "--output is required")
  }

  return Config(
    newTag: tag,
    target: target,
    previousTag: previousTag,
    outputPath: output,
    repoPath: repoPath,
    includeMerges: includeMerges
  )
}

func detectPreviousTag(newTag: String, repoPath: String) throws -> String? {
  let (status, out, err) = try run("/usr/bin/env", ["git", "tag", "--sort=-v:refname"], cwd: repoPath)
  guard status == 0 else {
    throw CLIError(message: "Failed to list tags: \(err.trimmingCharacters(in: .whitespacesAndNewlines))")
  }

  let tags = out
    .split(separator: "\n")
    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty }

  for tag in tags where tag != newTag {
    return tag
  }

  return nil
}

func collectCommits(range: String, repoPath: String, includeMerges: Bool) throws -> [(hash: String, subject: String)] {
  var args = ["git", "log", "--reverse", "--pretty=format:%h%x09%s"]
  if !includeMerges {
    args.append("--no-merges")
  }
  args.append(range)

  let (status, out, err) = try run("/usr/bin/env", args, cwd: repoPath)
  guard status == 0 else {
    throw CLIError(message: "Failed to collect commits for range '\(range)': \(err.trimmingCharacters(in: .whitespacesAndNewlines))")
  }

  return out
    .split(separator: "\n")
    .compactMap { line in
      let parts = line.split(separator: "\t", maxSplits: 1).map(String.init)
      guard parts.count == 2 else { return nil }
      return (hash: parts[0], subject: parts[1])
    }
}

func makeNotes(newTag: String, previousTag: String?, target: String, commits: [(hash: String, subject: String)], range: String) -> String {
  var lines: [String] = []

  if let previousTag {
    lines.append("## Changes since \(previousTag)")
  } else {
    lines.append("## Changes")
  }
  lines.append("")

  if commits.isEmpty {
    lines.append("- No non-merge commits found in this range.")
  } else {
    for commit in commits {
      lines.append("- \(commit.subject)")
    }
  }

  lines.append("")
  lines.append("## Commits")
  lines.append("")

  if commits.isEmpty {
    lines.append("- (none)")
  } else {
    for commit in commits {
      lines.append("- \(commit.hash) \(commit.subject)")
    }
  }

  lines.append("")
  lines.append("_Range: `\(range)` • Target: `\(target)` • Release: `\(newTag)`_")

  return lines.joined(separator: "\n") + "\n"
}

func main() throws {
  let config = try parseArgs(Array(CommandLine.arguments.dropFirst()))
  let previousTag = try config.previousTag ?? detectPreviousTag(newTag: config.newTag, repoPath: config.repoPath)
  let range = previousTag.map { "\($0)..\(config.target)" } ?? config.target
  let commits = try collectCommits(range: range, repoPath: config.repoPath, includeMerges: config.includeMerges)

  let notes = makeNotes(
    newTag: config.newTag,
    previousTag: previousTag,
    target: config.target,
    commits: commits,
    range: range
  )

  try notes.write(to: URL(fileURLWithPath: config.outputPath), atomically: true, encoding: .utf8)

  // Machine-readable-ish lines for callers.
  print("new_tag=\(config.newTag)")
  print("previous_tag=\(previousTag ?? "")")
  print("target=\(config.target)")
  print("range=\(range)")
  print("output=\(config.outputPath)")
}

do {
  try main()
} catch {
  fputs("Error: \(error)\n", stderr)
  printUsage()
  exit(1)
}
