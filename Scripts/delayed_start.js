// ***********************
// Use this script in the delayed start macro in Keyboard Maestro. You can get the list of apps using the bash script "list_installed_apps.sh"
// ************************

(function() {
    // Function to check if an app is running
    function isAppRunning(appName) {
        var runningApps = Application('System Events').processes().name();
        return runningApps.includes(appName);
    }

    // Function to recursively search for a file in a directory and its subdirectories
    function findFileInDirectory(directory, filename) {
        var fileManager = Application('Finder');
        try {
            var contents = fileManager.filesAndFoldersOf(directory).everyItem().name();
            if (contents.includes(filename)) {
                return true;
            }

            // Recursively search subdirectories
            for (var i = 0; i < contents.length; i++) {
                var itemPath = directory + '/' + contents[i];
                if (fileManager.kindOf(itemPath) === 'folder') {
                    if (findFileInDirectory(itemPath, filename)) {
                        return true;
                    }
                }
            }
        } catch (e) {
            console.error('Error searching in ' + directory + ': ' + e);
        }
        return false;
    }

    // Function to check if an app is installed
    function isAppInstalled(appName) {
        var appPath1 = '/Applications/' + appName + '.app';
        var appPath2 = '~/Applications/' + appName + '.app';

        try {
            var fileManager = Application('Finder');
            if (fileManager.fileExists(appPath1)) {
                return true;
            }
            if (fileManager.fileExists(appPath2)) {
                return true;
            }

            // Check subfolders in ~/Applications/
            if (findFileInDirectory('~/Applications/', appName + '.app')) {
                return true;
            }
        } catch (e) {
            console.error('Error checking app installation: ' + e);
            return false;
        }
    }

    // Function to start an app if not already running, with a delay and error handling
    function startAppWithDelay(appName, delay) {
        if (isAppInstalled(appName)) {
            if (!isAppRunning(appName)) {
                console.log('Starting ' + appName + '...');
                Application(appName).launch();
                $.NSRunLoop.currentRunLoop().runUntilDate($.NSDate.dateWithTimeIntervalSinceNow(delay));
            } else {
                console.log(appName + ' is already running.');
            }
        } else {
            console.log(appName + ' is not installed or has been uninstalled.');
        }
    }

    // Define the apps and their delays
        var apps = [
        { name: 'aText', delay: 5 },
        { name: 'Alfred 5', delay: 5 },
        { name: 'BetterTouchTool', delay: 5 },
        { name: 'Bitwarden', delay: 5 },
        { name: 'CleanShot X', delay: 5 },
        { name: 'Command X', delay: 5 },
        { name: 'Dato', delay: 5 },
        { name: 'Default Folder X', delay: 5 },
        { name: 'Fluor', delay: 5 },
        { name: 'Forecast Bar', delay: 5 },
        { name: 'Hazel', delay: 5 },
        { name: 'Ice', delay: 5 },
        { name: 'Monarch', delay: 5 },
        { name: 'Ollama', delay: 5 },
        { name: 'OpenIn', delay: 5 },
        { name: 'PopClip', delay: 5 },
        { name: 'Shareful', delay: 5 },
        { name: 'TextSniper', delay: 10 },

        { name: 'Docker', delay: 10 },

        ];


    // Start each app in order with the specified delay
    for (var i = 0; i < apps.length; i++) {
        startAppWithDelay(apps[i].name, apps[i].delay);
    }

    console.log('All apps have been processed.');
})();