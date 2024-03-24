module="use_alternative.sh"
alternative=$1
echo "Get $module"
source $module
get_current_python_alternative


if set_current_python3_alternative_as_priority 10000
then
    echo "Current python3 alternative set with priority 10000"
else
    echo "Could not set current python3 alternative with prioirity1"
fi

# install_python3_alternative_almalinux $alternative
# install_succesful=$?
# if $install_succesful == 0;
if install_python3_alternative_almalinux $alternative;
then
    echo "Sucess alternative python3.$alternative installed"
else
    echo "Sorry could not install alternative"
fi


if set_python3_alternative $alternative;
then
    echo "Sucess alternative python3.$alternative set"
else
    echo "Sorry could not set alternative python3.$alternative"
fi

echo "Running python test: python3 test_ver.py $alternative"
python3 test_ver.py $alternative
test_rc=$?
if [ $test_rc == 0 ]
then
    echo "Test Passed" 
else
    echo "Test Failed"
fi

sudo alternatives --auto python3