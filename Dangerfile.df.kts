import systems.danger.kotlin.*

danger(args) {
    val totalChangedFiles = git.createdFiles.size + git.modifiedFiles.size - git.deletedFiles.size

    // MARK: Big PR
    if(totalChangedFiles > 40) {
        fail("🚨 Big PR, please make it smaller.")
    } else if(totalChangedFiles > 20) {
        warn("⚠️ Big PR, try to keep changes smaller if you can")
    } else {
      message("✅ Small PR, good job!")
    }

    onGit {
        // MARK: Dangerfile changed
        if(modifiedFiles.contains("Dangerfile")) {
            warn("⚠️ This MR modified Dangerfile! Check the rules!")
        }

        // MARK: Too Many Commits
        if(commits.size >= 10) {
            warn("⚠️ Please keep pull requests to at most 10 commits.")
        }
    }

    onGitLab {
        if (mergeRequest.description.length < 10) {
            fail("🚨 Please provide a summary in the Merge Request description to help your colleagues understand the MR purpose.")
        }

        // MARK: Assignee needed
        if(mergeRequest.assignee == null) {
            warn("⚠️ Please assign someone to this MR.")
        }

        // Big PR Check
        if (mergeRequest.changesCount.toInt() > 100) {
            warn("⚠️ Big PR, try to keep changes smaller if you can")
        }

        // Work in progress check
        if (mergeRequest.title.contains("WIP", false)) {
            warn("⚠️ PR is classed as Work in Progress")
        }
    }

    if ((fails + warnings).isEmpty()) {
        message("🚀 No errors or warnings!")
    }
}