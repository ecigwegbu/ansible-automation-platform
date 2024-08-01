A collection of scripts, tools, playbooks, demos, etc related to the Ansible Automation Platform.

- installer-containerized-2.4.sh

  Install Ansible Automation Platform (AAP) version 2.4
  - using the containerized option, and optional post-install Config-As-Code
    usage: usage: 
      ./<this-script.sh> <tarball.tar.gz> <manifest.zip> [<post-install-repo-url> | false]
  - The config-as-code URL (if unspecified) defaults to
    'https://github.com/ecigwegbu/aap-cac' (specify 'false' instead if not required)
  - Replace all demo passwords (redhat) with your own for production or added security

Author Elias Igwegbu
(c) 2024. Unix Training Academy. All Rights Reserved
