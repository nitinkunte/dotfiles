/* --------------  GLOBALS -------------- */
let formattedData = '';

/* --------------  FILE UPLOAD -------------- */
$('#fileInput').on('change', function (e) {
    const file = e.target.files[0];
    if (!file) return;

    if (file.size > 50 * 1024 * 1024) { // 50 MB limit
        showError('File too large. Please use files under 50 MB.');
        return;
    }

    const reader = new FileReader();
    reader.onload = function (e) {
        $('#inputText').val(e.target.result);
        updateInputInfo();
        showSuccess(`File "${file.name}" loaded successfully!`);
    };
    reader.onerror = () => showError('Error reading file.');
    reader.readAsText(file);
});

/* --------------  VALIDATE JSONL -------------- */
async function validateJSONL() {
    const input = $('#inputText').val().trim();
    if (!input) {
        showError('Please provide input data.');
        return;
    }

    hideMessages();
    $('#validationResults').hide();
    $('#validateBtn').prop('disabled', true);
    $('#progressBar').show();
    $('#progressFill').css('width', '0%');

    const lines = input.split('\n');
    const totalLines = lines.length;
    let processed = 0;
    let valid = 0;
    let invalid = 0;
    const maxErrorsToShow = 10;
    const errors = [];

    const chunkSize = 1000;
    for (let i = 0; i < lines.length; i += chunkSize) {
        const chunk = lines.slice(i, i + chunkSize);
        for (const rawLine of chunk) {
            const line = rawLine.trim();
            if (!line) continue;

            try {
                JSON.parse(line);
                valid++;
            } catch (e) {
                invalid++;
                if (errors.length < maxErrorsToShow) {
                    errors.push(`Line ${processed + 1}: ${e.message}`);
                }
            }
            processed++;
        }
        const progress = (processed / totalLines) * 100;
        $('#progressFill').css('width', progress + '%');
        await new Promise(r => setTimeout(r, 0)); // keep UI responsive
    }

    $('#progressBar').hide();
    $('#validateBtn').prop('disabled', false);

    const $vr = $('#validationResults');
    if (invalid === 0) {
        $vr.removeClass('invalid').addClass('valid')
            .html(`✅ All ${valid.toLocaleString()} lines are valid JSON.`)
            .show();
    } else {
        let html = `❌ ${invalid.toLocaleString()} invalid line(s) found out of ${totalLines.toLocaleString()}.`;
        if (errors.length) {
            html += '<br><br><strong>First few errors:</strong><ul>';
            errors.forEach(err => html += `<li>${err}</li>`);
            html += '</ul>';
            if (invalid > maxErrorsToShow) html += `<em>… and ${invalid - maxErrorsToShow} more.</em>`;
        }
        $vr.removeClass('valid').addClass('invalid').html(html).show();
    }
}

/* --------------  FORMAT JSONL (unchanged) -------------- */
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
                    const parsed = JSON.parse(line);
                    let pretty = JSON.stringify(parsed, null, 2);
                    pretty = pretty.replace(/\\n/g, '\n');
                    result += pretty + (i + j < totalLines - 1 ? '\n' : '');
                } catch (e) {
                    result += line + (i + j < totalLines - 1 ? '\n' : '');
                    errors++;
                }
            }

            processedLines += chunk.length;
            const progress = (processedLines / totalLines) * 100;
            $('#progressFill').css('width', progress + '%');
            await new Promise(resolve => setTimeout(resolve, 0));
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

/* --------------  DOWNLOAD / UTILS (unchanged) -------------- */
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

function updateInputInfo() {
    const text = $('#inputText').val();
    const lines = text.trim() ? text.split('\n').length : 0;
    const bytes = new Blob([text]).size;
    $('#inputInfo').text(`${lines} lines, ${formatBytes(bytes)}`);
}

function updateOutputInfo() {
    const text = $('#outputText').val();
    const lines = text.trim() ? text.split('\n').length : 0;
    const bytes = new Blob([text]).size;
    $('#outputInfo').text(`${lines} lines, ${formatBytes(bytes)}`);

    const inputBytes = new Blob([$('#inputText').val()]).size;
    const ratio = inputBytes > 0 ? ((bytes / inputBytes) * 100).toFixed(1) : 0;
    $('#compressionRatio').text(`${ratio}%`);
}

function formatBytes(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function clearInput() {
    $('#inputText').val('');
    $('#outputText').val('');
    $('#fileInput').val('');
    formattedData = '';
    updateInputInfo();
    updateOutputInfo();
    $('#downloadBtn').prop('disabled', true);
    hideMessages();
    $('#validationResults').hide();
}

function showError(msg) { $('#errorMsg').text(msg).show(); $('#successMsg').hide(); }
function showSuccess(msg) { $('#successMsg').text(msg).show(); $('#errorMsg').hide(); }
function hideMessages() { $('#errorMsg, #successMsg').hide(); }

/* --------------  INITIAL SETUP -------------- */
$('#inputText').on('input', updateInputInfo);
updateInputInfo();
updateOutputInfo();