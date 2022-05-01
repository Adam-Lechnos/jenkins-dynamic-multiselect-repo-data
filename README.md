# jenkins-dynamic-multiselect-repo-data
Pull latest list of data from a GitHub repo directory for Jenkins Multi Select. Selects a directory to parse based on the command's supplied positions parameters such as region and environment

**Note:** An improved and cleaner version of [jenkins-multiselect-repo-data](../../../jenkins-multiselect-repo-data) which allows for multiple directories to be parsed based upon position parmeters

#### Intended Audience
* Devops

#### Pre-requisites
* GitHub repos containing a dedicated directroy for parsing into a list
* GitHub Access Token
* Variable substitution which provides a repo name and release tag using [semantic versioning](https://semver.org/)
* Variable substitution which provided a completion to lower level directories, such as environment and region for AWS

#### Usage
* Edit the script to include an `auth.cfg` for referencing a GitHub token assigned to the `gitauthtoken` variable. 
* The 'auth.cfg' file should be part of the `.gitignore` config.
* Edit the `logDir` varialbe to include the persistent directory structure in which data parsing against supplied repos should occur
  * i.e., `logDir=/foo/bar/`
* Execute the script as part of the Jenkins Multiselect function:
  * Supply two positional arguments to the script, *repository name* as the full git ssh address, and the *repository release tag*
  * i.e., `multi_selector_json.sh git@github.com:Adam-Lechnos/Binary-Init-Client.git v.0.0.1`
  * Supply the additional two positional parameters for lower level directory completion, below the persistent `logDir` variable.
    * The current script provides `region` and `env` however, these may be changes to accomdate the dynamic changes in the directory structure
    * i.e., /foo/bar/us-east-1/env
  * i.e., `multi_selector_json.sh git@github.com:Adam-Lechnos/Binary-Init-Client.git v.0.0.1 us-east-1 dev`
  * If data exists in the persistent directories root, the positional paramters for completing the directroy location will be ignored in favor of the root location  

#### Example
* Parse list of files from the FooBar repo's directory release v1.1.2
  * `multi_selector_json.sh git@github.com:Adam-Lechnos/FooBart.git v0.0.1 us-east-1 prod`

