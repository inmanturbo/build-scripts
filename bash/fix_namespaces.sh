#!/bin/bash

package_namespace="$1"

for file in $(find . -type f -name "*.php");
do
    sed -i "s/namespace App/namespace $package_namespace/g" "$file"
    sed -i "s/namespace Database/namespace $package_namespace\\\Database/g" "$file"
    sed -i "s/namespace Tests/namespace $package_namespace\\\Tests/g" "$file"
    sed -i "s/use Tests/use $package_namespace\\\Tests/g" "$file"
    sed -i "s/use App/use $package_namespace/g" "$file"
    sed -i "s/use Database/use $package_namespace\\\Database/g" "$file"
    sed -i "s/App\\\/$package_namespace\\\/g" "$file"
    sed -i "s/Database\\\/$package_namespace\\\Database/g" "$file"
    sed -i "s/Tests\\\/$package_namespace\\\Tests/g" "$file"

done