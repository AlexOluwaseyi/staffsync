// Javascript for password reset interactive page and pop-up
function toggleInput() {
    const selector = document.getElementById('option_selector').value;
    const newEntry = document.getElementById('new_entry');
    const existingEntry = document.getElementById('existing');
    

    if (selector === 'new_entry') {
        newEntry.style.display = 'block';
        existingEntry.style.display = 'none';
    } else if (selector === 'existing') {
        newEntry.style.display = 'none';
        existingEntry.style.display = 'block';
    } else {
        newEntry.style.display = 'none';
        existingEntry.style.display = 'none';
    }
    console.log(selector)
}

function confirmSubmission() {
    document.getElementById('reset-form').submit();
    document.getElementById('confirm-dialog').style.display = 'none';
    
}

function cancelOperation() {
    document.getElementById('confirm-dialog').close();
    document.getElementById('option_selector').value = '';
    document.getElementById('confirm-dialog').style.display = 'none';
}
