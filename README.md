A collection of scripts, tools, playbooks, demos, etc related to the Ansible Automation Platform.

1. installer-containerized-2.4.sh

  Install Ansible Automation Platform (AAP) version 2.4
  - using the containerized option, and optional post-install Config-As-Code
    usage: 
      ./<this-script.sh> <tarball.tar.gz> <manifest.zip> [<post-install-repo-url> | false]
  - The config-as-code URL (if unspecified) defaults to
    'https://github.com/ecigwegbu/aap-cac' (specify 'false' instead if not required)
  - Replace all demo passwords (redhat) with your own for production or added security

2. installer-aap-2.2.sh

  Install Ansible Automation Platform (AAP) version 2.2
  - Before running the script, create a secrets file 
    ~/.rhsm containing <redhat-username> <redhat-password>
  - Replace all demo passwords (redhat) with your own for production or added security
  - usage: 
      ./<this-script.sh>

Author Elias Igwegbu
(c) 2024. Unix Training Academy. All Rights Reserved
