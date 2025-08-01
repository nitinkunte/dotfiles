let formattedData = '';

// Handle file upload
$('#fileInput').on('change', function (e) {
    const file = e.target.files[0];
    if (!file) return;

    if (file.size > 50 * 1024 * 1024) { // 50MB limit
        showError('File too large. Please use files under 50MB.');
        return;
    }

    const reader = new FileReader();
    reader.onload = function (e) {
        $('#inputText').val(e.target.result);
        updateInputInfo();
        showSuccess(`File "${file.name}" loaded successfully!`);
    };
    reader.onerror = function () {
        showError('Error reading file.');
    };
    reader.readAsText(file);
});

// Update input info
function updateInputInfo() {
    const text = $('#inputText').val();
    const lines = text.trim() ? text.split('\n').length : 0;
    const bytes = new Blob([text]).size;
    $('#inputInfo').text(`${lines} lines, ${formatBytes(bytes)}`);
}

// Update output info
function updateOutputInfo() {
    const text = $('#outputText').val();
    const lines = text.trim() ? text.split('\n').length : 0;
    const bytes = new Blob([text]).size;
    $('#outputInfo').text(`${lines} lines, ${formatBytes(bytes)}`);

    const inputBytes = new Blob([$('#inputText').val()]).size;
    const ratio = inputBytes > 0 ? ((bytes / inputBytes) * 100).toFixed(1) : 0;
    $('#compressionRatio').text(`${ratio}%`);
}

// Format bytes
function formatBytes(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Clear input
function clearInput() {
    $('#inputText').val('');
    $('#outputText').val('');
    $('#fileInput').val('');
    formattedData = '';
    updateInputInfo();
    updateOutputInfo();
    $('#downloadBtn').prop('disabled', true);
    hideMessages();
}

// Format JSONL with streaming for large files
async function formatJSONL() {
    const input = $('#inputText').val().trim();
    if (!input) {
        showError('Please provide input data.');
        return;
    }

    hideMessages();
    $('#formatBtn').prop('disabled', true);
    $('#progressBar').show();
    $('#progressFill').css('width', '0%');

    const startTime = performance.now();
    const lines = input.split('\n');
    let processedLines = 0;
    const totalLines = lines.length;
    let errors = 0;

    try {
        const chunkSize = 1000;
        let result = '';

        for (let i = 0; i < lines.length; i += chunkSize) {
            const chunk = lines.slice(i, i + chunkSize);

            for (let j = 0; j < chunk.length; j++) {
                const line = chunk[j].trim();
                if (!line) continue;

                try {
                    // 1. parse the JSON
                    const parsed = JSON.parse(line);

                    // 2. stringify with pretty-printing
                    let pretty = JSON.stringify(parsed, null, 2);

                    // 3. turn literal "\n" into real newlines so it looks nice in the textarea
                    pretty = pretty.replace(/\\n/g, '\n');

                    result += pretty + (i + j < totalLines - 1 ? '\n' : '');
                } catch (e) {
                    // fallback: keep raw line
                    result += line + (i + j < totalLines - 1 ? '\n' : '');
                    errors++;
                }
            }

            processedLines += chunk.length;
            const progress = (processedLines / totalLines) * 100;
            $('#progressFill').css('width', progress + '%');
            await new Promise(resolve => setTimeout(resolve, 0)); // UI update
        }

        formattedData = result;
        $('#outputText').val(result);
        updateOutputInfo();

        const endTime = performance.now();
        $('#processingTime').text(`${((endTime - startTime) / 1000).toFixed(2)}s`);
        $('#downloadBtn').prop('disabled', false);

        if (errors > 0) {
            showSuccess(`Formatted ${totalLines - errors} lines successfully. ${errors} lines had errors.`);
        } else {
            showSuccess(`Successfully formatted ${totalLines} lines!`);
        }

    } catch (error) {
        showError('Error formatting JSONL: ' + error.message);
    } finally {
        $('#formatBtn').prop('disabled', false);
        $('#progressBar').hide();
    }
}

// Download formatted JSONL
function downloadJSONL() {
    if (!formattedData) {
        showError('No formatted data to download.');
        return;
    }

    const blob = new Blob([formattedData], { type: 'application/jsonl' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'formatted.jsonl';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

// Show error message
function showError(message) {
    $('#errorMsg').text(message).show();
    $('#successMsg').hide();
}

// Show success message
function showSuccess(message) {
    $('#successMsg').text(message).show();
    $('#errorMsg').hide();
}

// Hide messages
function hideMessages() {
    $('#errorMsg, #successMsg').hide();
}

// Update input info on change
$('#inputText').on('input', updateInputInfo);

// Initial setup
updateInputInfo();
updateOutputInfo();