# Fetch GH Release Asset from one repository and publish to Another.

This action replicates a Github release from one repository to another. Private repos are supported.

## Inputs

### `repo`

The `org/repo`. Defaults to the current repo.

### `version`

The release version to fetch from. Default `"latest"`. If not `"latest"`, this has to be in the form `tags/<tag_name>` or `<release_id>`.

### `file`

**Required** The name of the file in the release.

### `token`

Optional Personal Access Token to access repository. You need to either specify this or use the ``secrets.GITHUB_TOKEN`` environment variable. Note that if you are working with a private repository, you cannot use the default ``secrets.GITHUB_TOKEN`` - you have to set up a personal access token with at least the scope org.

### `release_repo`

The `org/repo` to make release to. Defaults to the current repo.

### `release_version`

The release version for the new repository. Default `"latest"`. If not `"latest"`, this has to be in the form `tags/<tag_name>` or `<release_id>`.

### `release_target`

Optional target file path for the new release. Only supports paths to subdirectories of the Github Actions workspace directory

## Outputs

### `version`

The version number of the release tag. Can be used to deploy for example to v1.0.0

## Example usage

```yaml
uses: kumarabd/publish-release-to-another-action@v1.0.0
with:
  repo: "kumarabd/random"
  version: "latest"
  file: "random-linux.zip"
  target: "subdir/random-linux.zip"
  token: ${{ secrets.YOUR_TOKEN }}
```