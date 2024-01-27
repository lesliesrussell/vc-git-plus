;;; vc-git-plus.el --- Version control utilities for Git

;; Author: Leslie S. Russell <lesliesrussell@gmail.com>
;; Version: 1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: git, version control
;; URL:

;;; Commentary:

;; The vc-git-plus package is an Emacs utility designed to enhance the experience of working with Git repositories directly from Emacs. This package is tailored for developers who prefer to integrate their version control workflow into their Emacs environment, offering a range of convenient Git operations without leaving the editor.

;; Features:
;; - Initialize Git Repositories: Quickly initialize a new Git repository in the current directory.
;; - Branch Management: Easily delete Git branches with a simple selection interface.
;; - Get Branch List: Retrieve and display a list of all branches in the current Git repository.
;; - Check Git Status: Instantly view the status of your Git repository.
;; - Enhanced Cloning: Clone Git repositories with additional options like specifying branches, handling local paths, and setting target directories.

;; Usage:
;; - To initialize a Git repository, simply call `vc-git-init`.
;; - Use `vc-git-branch-delete` to select and delete a branch.
;; - Retrieve a list of branches with `vc-git-get-branches`.
;; - To check the status of your current Git repository, use `vc-git-status`.
;; - Clone repositories using `vc-git-clone` with customizable arguments for more control.

;; This package is designed for Emacs users who are looking for an integrated solution to manage Git repositories. It aims to simplify the Git workflow in Emacs, making it more efficient and user-friendly.

;; Installation:
;; Place `vc-git-plus.el` in your Emacs load-path. Add `(require 'vc-git-plus)` to your Emacs configuration file.

;; Contributions and Feedback:
;; Contributions to vc-git-plus are welcome. Please submit pull requests or issues on the GitHub repository [Your GitHub Repo URL]. Feedback and suggestions for improvements are also appreciated.

;;; Code:

(defun vc-git-init ()
  "Initialize a new Git repository in the current directory."
  (interactive)
  (let ((default-directory (expand-file-name default-directory)))
    (shell-command "git init")))

(defun vc-git-branch-delete ()
  "Delete a Git branch after selecting from a list."
  (interactive)
  (let ((branch (completing-read "Select branch to delete: " (vc-git-get-branches))))
    (when (and (not (string= branch ""))
               (yes-or-no-p (format "Are you sure you want to delete the branch '%s'? " branch)))
      (shell-command (format "git branch -d %s" (shell-quote-argument branch)))
      (message "Branch '%s' deleted" branch))))

(defun vc-git-get-branches ()
  "Return a list of Git branches."
  (let ((default-directory (vc-git-root default-directory)))
    (unless default-directory
      (error "Not in a Git repository"))
    (split-string (shell-command-to-string "git branch --format='%(refname:short)'") "\n" t)))

(defun vc-git-status ()
  "Run git status on the current directory and display the results."
  (interactive)
  (shell-command "git status"))

(defmacro vc-git-clone (&rest args)
  "Clone a git repository with given ARGS.

Optional keywords:
:url - specifies the repository URL or local path.
:directory - specifies the target directory.
:branch - specifies the branch to clone.
:local - if t, treats the URL as a local repository path."
  `(let* ((url (plist-get ',args :url))
          (directory (plist-get ',args :directory))
          (branch (plist-get ',args :branch))
          (local (plist-get ',args :local)))
     (unless url
       (error "URL or local path not provided"))
     (if local
         (progn
           (unless (and (file-exists-p url) (file-directory-p (concat url "/.git")))
             (error "Invalid local repository path"))
           (let ((command (concat "git clone "
                                  (when branch (concat "--branch " branch " "))
                                  (shell-quote-argument url)
                                  (when directory (concat " " (shell-quote-argument directory))))))
             (message "Cloning local repository: %s" url)
             (start-process "vc-git-clone-process" "*vc-git-clone-output*" "sh" "-c" command)
             (message "Local repository cloned successfully.")))
       (let ((command (concat "git clone "
                              (when branch (concat "--branch " branch " "))
                              url
                              (when directory (concat " " directory)))))
         (message "Cloning remote repository: %s" url)
         (start-process "vc-git-clone-process" "*vc-git-clone-output*" "sh" "-c" command)
         (message "Remote repository cloned successfully.")))))


;; (vc-git-clone :url "https://github.com/lesliesrussell/Sanemacs/")
;; (vc-git-clone :url "~/.sandbox/testing/Sanemacs"
;; 	      :directory "~/.sandbox/testing/my-sanemacs/"
;; 	      :local t)

(provide 'vc-git-plus)
;;; vc-git.el ends here
