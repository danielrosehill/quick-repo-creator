#!/usr/bin/env python3
"""
QuickRepo CLI - Streamline repository creation workflow
Author: Daniel Rosehill
"""

import os
import sys
import subprocess
import re
from pathlib import Path


class QuickRepo:
    def __init__(self):
        self.github_base = Path("/home/daniel/repos/github")
        self.huggingface_base = Path("/home/daniel/repos/hugging-face")
        
    def sanitize_repo_name(self, name: str) -> str:
        """Convert repo name to URL-safe format"""
        # Convert to lowercase and replace spaces/special chars with hyphens
        sanitized = re.sub(r'[^a-zA-Z0-9\s-]', '', name)
        sanitized = re.sub(r'\s+', '-', sanitized.strip())
        sanitized = sanitized.lower()
        # Remove multiple consecutive hyphens
        sanitized = re.sub(r'-+', '-', sanitized)
        # Remove leading/trailing hyphens
        sanitized = sanitized.strip('-')
        return sanitized
    
    def get_repo_name(self) -> str:
        """Get repository name from user input"""
        while True:
            name = input("Please provide a name for the repository: ").strip()
            if name:
                sanitized = self.sanitize_repo_name(name)
                if sanitized != name:
                    confirm = input(f"Repository name will be: '{sanitized}'. Continue? (y/n): ").strip().lower()
                    if confirm in ['y', 'yes', '']:
                        return sanitized
                    # If user says no, ask for name again
                    continue
                return sanitized
            print("Repository name cannot be empty. Please try again.")
    
    def get_repo_type(self) -> str:
        """Get repository type from user input"""
        while True:
            choice = input("What type of repo is this?\n1) GitHub (default)\n2) Hugging Face\nChoice (1-2): ").strip()
            if choice == '' or choice == '1':
                return 'github'
            elif choice == '2':
                return 'huggingface'
            else:
                print("Invalid choice. Please enter 1 or 2.")
    
    def get_privacy_setting(self) -> str:
        """Get privacy setting from user input"""
        while True:
            choice = input("Should this repo be public or private?\n1) Private (default)\n2) Public\nChoice (1-2): ").strip()
            if choice == '' or choice == '1':
                return 'private'
            elif choice == '2':
                return 'public'
            else:
                print("Invalid choice. Please enter 1 or 2.")
    
    def check_gh_auth(self) -> bool:
        """Check if GitHub CLI is authenticated"""
        try:
            result = subprocess.run(['gh', 'auth', 'status'], 
                                  capture_output=True, text=True, check=False)
            return result.returncode == 0
        except FileNotFoundError:
            print("Error: GitHub CLI (gh) is not installed or not in PATH")
            return False
    
    def create_github_repo(self, repo_name: str, privacy: str) -> bool:
        """Create GitHub repository"""
        repo_path = self.github_base / repo_name
        
        # Check if directory already exists
        if repo_path.exists():
            print(f"Error: Directory {repo_path} already exists!")
            return False
        
        try:
            # Create directory
            repo_path.mkdir(parents=True, exist_ok=True)
            print(f"Created directory: {repo_path}")
            
            # Initialize git repo
            subprocess.run(['git', 'init'], cwd=repo_path, check=True, capture_output=True)
            print("Initialized git repository")
            
            # Create README.md
            readme_path = repo_path / "README.md"
            with open(readme_path, 'w') as f:
                f.write(f"# {repo_name}\n\nRepository created with QuickRepo CLI\n")
            print("Created README.md")
            
            # Add and commit README
            subprocess.run(['git', 'add', 'README.md'], cwd=repo_path, check=True, capture_output=True)
            subprocess.run(['git', 'commit', '-m', 'Initial commit'], cwd=repo_path, check=True, capture_output=True)
            print("Committed initial files")
            
            # Create GitHub repo and push
            privacy_flag = '--private' if privacy == 'private' else '--public'
            subprocess.run(['gh', 'repo', 'create', repo_name, privacy_flag, '--source=.', '--push'], 
                         cwd=repo_path, check=True, capture_output=True)
            print(f"Created and pushed to GitHub repository: {repo_name}")
            
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"Error during repository creation: {e}")
            # Clean up on failure
            if repo_path.exists():
                import shutil
                shutil.rmtree(repo_path)
            return False
        except Exception as e:
            print(f"Unexpected error: {e}")
            return False
    
    def get_ide_choice(self) -> str:
        """Get IDE choice from user"""
        while True:
            choice = input("\nWould you like to open the repo in an IDE?\n"
                         "1) Windsurf\n"
                         "2) VS Code\n"
                         "3) Code Insiders\n"
                         "4) No, thanks\n"
                         "Choice (1-4): ").strip()
            
            if choice == '1':
                return 'windsurf'
            elif choice == '2':
                return 'vscode'
            elif choice == '3':
                return 'code-insiders'
            elif choice == '4':
                return 'none'
            else:
                print("Invalid choice. Please enter 1-4.")
    
    def open_in_ide(self, repo_path: Path, ide: str):
        """Open repository in chosen IDE"""
        if ide == 'none':
            return
        
        commands = {
            'windsurf': ['windsurf', str(repo_path)],
            'vscode': ['code', str(repo_path)],
            'code-insiders': ['code-insiders', str(repo_path)]
        }
        
        if ide not in commands:
            print(f"Unknown IDE: {ide}")
            return
        
        try:
            # Use Popen to start the process and detach it
            subprocess.Popen(commands[ide], 
                           stdout=subprocess.DEVNULL, 
                           stderr=subprocess.DEVNULL,
                           start_new_session=True)
            print(f"Opening repository in {ide.replace('-', ' ').title()}...")
            print("You can now close this terminal - the IDE will remain open.")
        except FileNotFoundError:
            print(f"Error: {ide} is not installed or not in PATH")
        except Exception as e:
            print(f"Error opening IDE: {e}")
    
    def run(self):
        """Main CLI workflow"""
        print("🚀 QuickRepo CLI - Fast Repository Creation")
        print("=" * 45)
        
        # Check GitHub CLI authentication
        if not self.check_gh_auth():
            print("Please authenticate with GitHub CLI first: gh auth login")
            sys.exit(1)
        
        # Get user inputs
        repo_name = self.get_repo_name()
        repo_type = self.get_repo_type()
        privacy = self.get_privacy_setting()
        
        print(f"\n📋 Summary:")
        print(f"Repository name: {repo_name}")
        print(f"Type: {repo_type.title()}")
        print(f"Privacy: {privacy.title()}")
        
        confirm = input("\nProceed with creation? (y/n): ").strip().lower()
        if confirm not in ['y', 'yes', '']:
            print("Repository creation cancelled.")
            sys.exit(0)
        
        # Create repository based on type
        if repo_type == 'github':
            success = self.create_github_repo(repo_name, privacy)
            repo_path = self.github_base / repo_name
        else:
            print("Hugging Face repository creation will be implemented later.")
            sys.exit(1)
        
        if success:
            print(f"\n✅ Success! Repository '{repo_name}' created successfully!")
            print(f"📁 Location: {repo_path}")
            
            # Offer to open in IDE
            ide_choice = self.get_ide_choice()
            self.open_in_ide(repo_path, ide_choice)
        else:
            print("\n❌ Repository creation failed!")
            sys.exit(1)


def main():
    try:
        cli = QuickRepo()
        cli.run()
    except KeyboardInterrupt:
        print("\n\nOperation cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print(f"\nUnexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
