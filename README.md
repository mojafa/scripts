# Repository Management Toolkit

This repository contains scripts and files designed to automate and simplify common repository management tasks like cloning, forking, creating pull requests, and deleting repositories.


## Scripts Overview

### 1. **fork_clone_gco.sh**
Automates the process of forking a repository, cloning it locally, and checking out a branch.

#### Steps to Use:

1. Make the script executable:  
   ```bash
   chmod +x fork_clone_gco.sh
2. Create a text file such as`repos.txt` with one Github repository URL per line. Example:
     ```bash
    https://github.com/owner/repo
    https://github.com/owner/repo/blob/commit/dir/file
3. Run the script:
    ```bash
    ./fork_clone_gco.sh repos.txt
    ```


### 2. **commit_push_create_pr.sh**

This script automates the process of committing changes to a repository, pushing them to a new branch, and creating a pull request.


#### Usage:

    ```bash
    ./commit_push_create_pr.sh <branch-name> <commit-message>
    ```

### 3. **delete_repo.sh**

This script automates the process of deleting a repository from Github.

#### Usage:

    ```bash
    ./delete_repo.sh <repository-name>
    ```