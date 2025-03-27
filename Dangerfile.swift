import Danger

let danger = Danger()
let git = danger.git
let gitLab = danger.gitLab

let totalChangedFiles = git.createdFiles.count + git.modifiedFiles.count - git.deletedFiles.count

// MARK: Big PR
if totalChangedFiles > 40 {
    fail("🚨 Big PR, please make it smaller.")
} else if totalChangedFiles > 20 {
    warn("⚠️ Big PR, try to keep changes smaller if you can")
} else {
    message("✅ Small PR, good job!")
}

// MARK: Dangerfile changed
if git.modifiedFiles.contains("Dangerfile") {
    warn("⚠️ This MR modified Dangerfile! Check the rules!")
}

// MARK: Too Many Commits
if git.commits.count >= 10 {
    warn("⚠️ Please keep pull requests to at most 10 commits.")
}

// MARK: Total lines of code
let allSourceFiles = danger.git.modifiedFiles + danger.git.createdFiles
if !allSourceFiles.isEmpty {
    let totalLinesOfCode = allSourceFiles.reduce(0) { partialResult, file in

        if let diff = try?  danger.utils.diff(forFile: file, sourceBranch: danger.gitLab.mergeRequest.targetBranch).get() {
            let changes = diff.changes
            switch changes {
            case .created(let addedLines):
                return partialResult + addedLines.count
            case .deleted(let deletedLines):
                return partialResult + deletedLines.count
            default:
                return partialResult + 0
            }
        } else {
            return partialResult + 0
        }
    }

    if totalLinesOfCode > 600 {
        fail("🚨 Files should contain less than 600 lines of code.")

    } else if totalLinesOfCode > 400 {
        warn("⚠️ Consider keeping changes to less than 400 lines of code.")
    }
}


if let gitLab {
    // MARK: Merge Request Description
    if (gitLab.mergeRequest.description.count < 10) {
        fail("🚨 Please provide a summary in the Merge Request description to help your colleagues understand the MR purpose.")
    }


    // MARK: Assignee needed
    if gitLab.mergeRequest.assignee == nil {
        warn("⚠️ Please assign someone to this MR.")
    }

}

// MARK: Swiftlint
let lintIssues = SwiftLint.lint(.all(directory: "."), configFile: ".swiftlint.yml")
if lintIssues.isEmpty {
    message("🎉 Great job! No SwiftLint issues found.")
} else {
    lintIssues.forEach { issue in
        if issue.severity == .error {
            fail(issue.toMarkdown())
        }
    }
}
