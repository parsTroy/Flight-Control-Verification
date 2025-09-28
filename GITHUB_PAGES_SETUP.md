# GitHub Pages Setup Guide

This guide helps you set up GitHub Pages deployment for the Flight Control Verification project.

## Automatic Deployment (Recommended)

The project includes a GitHub Actions workflow that should automatically deploy to GitHub Pages when you push to the main branch.

### Prerequisites

1. **Enable GitHub Pages in Repository Settings:**
   - Go to your repository on GitHub
   - Click "Settings" tab
   - Scroll down to "Pages" section
   - Under "Source", select "GitHub Actions"
   - Save the settings

2. **Verify Workflow Permissions:**
   - Go to "Settings" → "Actions" → "General"
   - Under "Workflow permissions", select "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"
   - Save changes

### How It Works

1. Push changes to the `main` branch
2. GitHub Actions automatically runs the deployment workflow
3. The workflow builds the project and deploys to GitHub Pages
4. Your site will be available at: `https://parsTroy.github.io/Flight-Control-Verification/`

## Manual Deployment (Backup Method)

If automatic deployment fails, you can deploy manually:

### Method 1: Using the Deploy Script

```bash
# Run the deployment script
./deploy.sh

# Follow the instructions printed by the script
```

### Method 2: Manual Steps

1. **Create gh-pages branch:**
   ```bash
   git checkout -b gh-pages
   ```

2. **Build the project:**
   ```bash
   # Copy web files to root
   cp -r web/* .
   
   # Copy documentation
   mkdir -p docs
   cp -r web/docs/* docs/
   
   # Create .nojekyll file
   touch .nojekyll
   ```

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "Deploy to GitHub Pages"
   git push origin gh-pages
   ```

4. **Enable GitHub Pages:**
   - Go to repository Settings → Pages
   - Select "Deploy from a branch"
   - Choose "gh-pages" branch
   - Select "/ (root)" folder
   - Save

## Troubleshooting

### Common Issues

**403 Permission Denied Error:**
- Ensure GitHub Pages is enabled in repository settings
- Check that workflow permissions are set to "Read and write"
- Verify the repository is public (required for free GitHub Pages)

**Workflow Not Running:**
- Check that GitHub Actions is enabled in repository settings
- Ensure the workflow file is in `.github/workflows/`
- Verify the workflow syntax is correct

**Site Not Updating:**
- Wait a few minutes for GitHub Pages to update
- Check the Actions tab for any failed workflows
- Clear your browser cache

**Files Not Found:**
- Ensure all files are properly copied to the build directory
- Check that file paths are correct
- Verify the .nojekyll file exists

### Alternative Hosting Options

If GitHub Pages continues to have issues, consider these alternatives:

1. **Netlify:**
   - Drag and drop the `build` folder to netlify.com
   - Connect your GitHub repository for automatic deployments

2. **Vercel:**
   - Connect your GitHub repository to vercel.com
   - Automatic deployments on every push

3. **GitHub Codespaces:**
   - Use GitHub Codespaces to run the project locally
   - Access via the provided URL

## Verification

Once deployed, verify the following:

- [ ] Main page loads correctly
- [ ] Navigation works between sections
- [ ] Simulation interface is functional
- [ ] Testing interface works
- [ ] Documentation is accessible
- [ ] All charts and visualizations display properly
- [ ] Mobile responsiveness works

## Support

If you continue to have issues:

1. Check the GitHub Actions logs for specific error messages
2. Verify all repository settings are correct
3. Try the manual deployment method
4. Consider using an alternative hosting service

The project is designed to work with any static hosting service, so you have multiple deployment options available.
