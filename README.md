# QuickRepo CLI

A streamlined CLI tool to speed up repository creation workflow for GitHub and Hugging Face repositories.

## Features

- 🚀 **Fast repository creation** with interactive prompts
- 🔄 **Automatic name sanitization** (converts "Quick Repo Maker" → "quick-repo-maker")
- 🏠 **Organized storage** in predefined directories
- 🔐 **Privacy control** (public/private repositories)
- 🛠️ **IDE integration** (Windsurf, VS Code, Code Insiders)
- ✨ **GitHub CLI integration** for seamless repo creation and pushing

## Prerequisites

- Python 3.6+
- Git
- GitHub CLI (`gh`) - Install with: `sudo apt install gh`
- GitHub CLI authentication: `gh auth login`

## Installation

1. Clone or download this repository
2. Run the installation script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

This will create a symlink in `/usr/local/bin/quickrepo` so you can use the command from anywhere.

## Usage

Simply run:
```bash
quickrepo
```

The CLI will guide you through:

1. **Repository name**: Enter any name (will be auto-sanitized)
2. **Repository type**: 
   - GitHub (default)
   - Hugging Face (coming soon)
3. **Privacy setting**:
   - Private (default)
   - Public

### Workflow for GitHub Repositories

1. Creates directory in `/home/daniel/repos/github/`
2. Initializes git repository
3. Creates initial README.md
4. Commits initial files
5. Creates GitHub repository using `gh`
6. Pushes to GitHub
7. Offers to open in your preferred IDE

### IDE Integration

After successful creation, you can choose to open the repository in:
- **Windsurf**: `windsurf ~/repos/github/repo-name`
- **VS Code**: `code ~/repos/github/repo-name`
- **Code Insiders**: `code-insiders ~/repos/github/repo-name`

The IDE process will detach from the terminal, so you can close the terminal session.

## Directory Structure

- **GitHub repos**: `/home/daniel/repos/github/`
- **Hugging Face repos**: `/home/daniel/repos/hugging-face/` (future)

## Example Session

```
🚀 QuickRepo CLI - Fast Repository Creation
=============================================

Please provide a name for the repository: My Awesome Project
Repository name will be: 'my-awesome-project'. Continue? (y/n): y

What type of repo is this?
1) GitHub (default)
2) Hugging Face
Choice (1-2): 1

Should this repo be public or private?
1) Private (default)
2) Public
Choice (1-2): 1

📋 Summary:
Repository name: my-awesome-project
Type: Github
Privacy: Private

Proceed with creation? (y/n): y

Created directory: /home/daniel/repos/github/my-awesome-project
Initialized git repository
Created README.md
Committed initial files
Created and pushed to GitHub repository: my-awesome-project

✅ Success! Repository 'my-awesome-project' created successfully!
📁 Location: /home/daniel/repos/github/my-awesome-project

Would you like to open the repo in an IDE?
1) Windsurf
2) VS Code
3) Code Insiders
4) No, thanks
Choice (1-4): 1

Opening repository in Windsurf...
You can now close this terminal - the IDE will remain open.
```

## Troubleshooting

### GitHub CLI Not Authenticated
```bash
gh auth login
```

### Permission Issues
Make sure the install script has execute permissions:
```bash
chmod +x install.sh
```

### Command Not Found
Ensure `/usr/local/bin` is in your PATH:
```bash
echo $PATH
```

## Future Enhancements

- [ ] Hugging Face repository creation
- [ ] Template support for different project types
- [ ] Configuration file for custom paths
- [ ] Batch repository creation
- [ ] Integration with other git hosting services

## Author

Daniel Rosehill - [danielrosehill.com](https://danielrosehill.com)
