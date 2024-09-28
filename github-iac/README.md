# Setup addon repositories

## FAQ:

### Import an existing repository

* The repository needs to be declared in the `addon.yml` file on the organisation repository `repository`.
* Execute command like `terraform import 'github_repository.addons[\"ympd\"]' ympd` to import the existing state.

### Add new repository

1. Add repository to the `addon.yml` file on the organisation repository `repository`
2. Workflow will automatically trigger to create new addon repo.
