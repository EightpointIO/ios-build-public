const { danger, fail, warn, message } = require('danger');

const createdFiles = danger.git.created_files || [];
const modifiedFiles = danger.git.modified_files || [];
const deletedFiles = danger.git.deleted_files || [];
const commits = danger.git.commits || [];

const totalChangedFiles = createdFiles.length + modifiedFiles.length - deletedFiles.length;

// Big PR Checks
if (totalChangedFiles > 40) {
    fail("🚨 Big PR, please make it smaller.");
} else if (totalChangedFiles > 20) {
    warn("⚠️ Big PR, try to keep changes smaller if you can.");
} else if (totalChangedFiles > 0) {
    message("✅ Small PR, good job!");
} else {
    warn("⚠️ No files changed in this PR/MR.");
}

// Check if Dangerfile was modified
if (modifiedFiles.includes("Dangerfile")) {
    warn("⚠️ This MR modified Dangerfile! Check the rules!");
}

// Check if there are too many commits
if (commits.length >= 10) {
    warn("⚠️ Please keep pull requests to at most 10 commits.");
}

// GitLab-specific checks
if (danger.gitlab && danger.gitlab.mr) {
    const mr = danger.gitlab.mr;

    if (mr.body && mr.body.length < 10) {
        fail("🚨 Please provide a summary in the Merge Request description to help your colleagues understand the MR purpose.");
    }

    if (!mr.assignee) {
        warn("⚠️ Please assign someone to this MR.");
    }

    if (mr.changes_count && mr.changes_count > 100) {
        warn("⚠️ Big PR, try to keep changes smaller if you can.");
    }

    if (mr.title.includes("WIP")) {
        warn("⚠️ PR is classed as Work in Progress");
    }
}

const failures = danger.failures || [];
const warnings = danger.warnings || [];

// Final message if there are no errors or warnings
if (failures.length === 0 && warnings.length === 0) {
    message("🚀 No errors or warnings!");
}
