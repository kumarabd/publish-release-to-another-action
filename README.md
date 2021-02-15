# Fetch GH Release Asset from one repository and publish to Another.

This action replicates a Github release from one repository to another. Private repos are supported.

## Inputs

### `repo`

The `org/repo`. Defaults to the current repo.

### `version`

The release version to fetch from. Default `"latest"`. If not `"latest"`, this has to be in the form `tags/<tag_name>` or `<release_id>`.

### `file`

**Required** The name of the file in the release.

### `target`

Optional target file path. Only supports paths to subdirectories of the Github Actions workspace directory

### `token`

Optional Personal Access Token to access repository. You need to either specify this or use the ``secrets.GITHUB_TOKEN`` environment variable. Note that if you are working with a private repository, you cannot use the default ``secrets.GITHUB_TOKEN`` - you have to set up a personal access token with at least the scope org.

## Outputs

### `version`

The version number of the release tag. Can be used to deploy for example to v1.0.0

## Example usage

```yaml
uses: kumarabd/publish-release-to-another-action@master
with:
  repo: "kumarabd/random"
  version: "latest"
  file: "random-linux.zip"
  target: "subdir/random-linux.zip"
  token: ${{ secrets.YOUR_TOKEN }}
```