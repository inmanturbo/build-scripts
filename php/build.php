<?php

if ($argc < 2) {
    echo "Usage: php script.php <branch_B> [build_directory]\n";
    exit(1);
}

$branchB = $argv[1];
$buildDir = $argc > 2 ? $argv[2] : 'build';

exec('git rev-parse --abbrev-ref HEAD', $outputBranchA);
$branchA = trim($outputBranchA[0]);

exec("git diff --name-status $branchA..$branchB", $diffLines);

foreach ($diffLines as $line) {
    [$status, $file] = preg_split('/\s+/', $line);
    if ($status == 'D') {
        continue;
    }

    $destPath = $buildDir . '/' . $file;
    @mkdir(dirname($destPath), 0777, true);

    exec("git show $branchB:\"$file\"", $fileContents);
    file_put_contents($destPath, implode("\n", $fileContents));
    unset($fileContents); // Clear the contents for the next iteration
}

echo "Files from branch $branchB have been copied to the $buildDir directory.\n";
