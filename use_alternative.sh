get_current_python_alternative() {
    current_alternative=$(readlink /usr/bin/python3)
    echo "Current Python alternative: $current_alternative"

    if [[ $current_alternative=="/etc/alternatives/python3" ]]
    then
        echo "Already using alternatives, Checking the python3 path from alteantives /etc/alternatives/python3"
        current_alternative=$(readlink /etc/alternatives/python3)
        echo "Real Current Python alternative: $current_alternative"
    fi
}

set_python3_alternative(){
    local version="$1"

    sudo alternatives --set python3 /usr/bin/python3.$version 
    is_alternative_set=$?
    echo "Return code: $is_alternative_set"
    if [[ $is_alternative_set == 0 ]]
    then
        echo "/usr/bin/python3.$version set as an alternative"
        true; return
    else
        echo "/usr/bin/python3.$version NOT set as an alternative"
        false; return
    fi
}


set_current_python3_alternative_as_priority(){
    local priority="$1"

    # current_alternative=$(python3 -c "import sys;print(f\"{sys.version_info.minor}\")")
    # echo "Current Python alternative: $current_alternative"

    # current_alternative=$(readlink /usr/bin/python3)
    current_alternative=$(readlink /etc/alternatives/python3)
    echo "Current Python alternative: $current_alternative"

    sudo alternatives --install /usr/bin/python3 python3 $current_alternative $priority
    is_alternative_set=$?
    echo "Return code: $is_alternative_set"
    if [[ $is_alternative_set == 0 ]]
    then
        echo "$current_alternative installed as an alternative with priority=$priority"
        true; return
    else
        echo "$current_alternative NOT installed as an alternative with priority=$priority"
        false; return
    fi

}

install_python3_alternative_almalinux() {
    local version="$1"
    
    # Install the desired Python 3 version
    # sudo dnf upgrade -y
    echo "About to run: sudo dnf search python3.$version"
    sudo dnf search python3.$version
    echo "About to run: sudo dnf install -y python3.$version"
    sudo dnf install -y python3.$version
    install_rc=$?
    echo "Return code: $install_rc"
    
    if [[ $install_rc == 0 ]]
    then
        echo "Python 3.$version installed."
        # true; return
    else
        echo "Python 3.$version NOT installed."
        false; return
    fi
    
    # Set it as an alternative
    echo "About to run: sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.$version 1"
    sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.$version 1
    is_alternative_set=$?
    echo "Return code: $is_alternative_set"
    if [[ $install_rc == 0 ]]
    then
        echo "Python 3.$version set as an alternative."
        true; return
    else
        echo "Python 3.$version NOT set as an alternative."
        false; return
    fi

}


install_python3_alternative_ubuntu() {
    local version="$1"
    
    # Install the desired Python 3 version
    sudo apt-get update
    sudo apt-get install -y python3-$version
    
    # Set it as an alternative
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.$version 100
    
    echo "Python 3.$version installed and set as an alternative."
}


install_python3_alternative_rhel() {
    local version="$1"
    
    # Install the desired Python 3 version
    sudo yum install -y python3.$version
    
    # Set it as an alternative
    sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.$version 100
    
    echo "Python 3.$version installed and set as an alternative."
}

# Function to modify the Python 3 alternative, run a Python script, and set back the default one
run_script_with_python3_alternative() {
    local new_version="$1"
    local python_script="$2"

    # Get the current Python 3 alternative
    local original_alternative=$(readlink /usr/bin/python3)
    echo "Current Python alternative: $current_alternative"

    # Check if the current version is lower than the specified version
    current_version=$(echo "$original_alternative" | sed 's|/usr/bin/python3\.||')
    if [ -z "$current_version" ]; then
        echo "Error: Unable to determine current Python 3 version."
        exit 1
    fi
    if (( $(echo "$current_version < $new_version" | bc -l) )); then
        # Install the new Python 3 alternative
        install_python_alternative "$new_version"
    fi

    # Set the new Python 3 alternative
    sudo alternatives --set python3 /usr/bin/python3.$new_version
    echo "New Python 3 alternative set: /usr/bin/python3.$new_version"

    # Run the Python script with the new alternative
    echo "Running Python script with alternative:"
    python3 "$python_script"

    # Set back the original Python 3 alternative
    sudo alternatives --set python3 "$original_alternative"
    echo "Original Python 3 alternative restored: $original_alternative"
}
