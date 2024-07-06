// Javascript for password reset interactive page and pop-up
function toggleInput() {
    const selector = document.getElementById('account_selector').value;
    const emailInput = document.getElementById('email_input');
    const staffInput = document.getElementById('staff_input');
    

    if (selector === 'email') {
        emailInput.style.display = 'block';
        staffInput.style.display = 'none';
    } else if (selector === 'staff_id') {
        emailInput.style.display = 'none';
        staffInput.style.display = 'block';
    } else {
        emailInput.style.display = 'none';
        staffInput.style.display = 'none';
    }
    console.log(selector)
}

function confirmSubmission() {
    // const confirmDialog = document.getElementById('confirm-dialog')
    // confirmDialog.style.display = 'block';
    document.getElementById('reset-form').submit();
    // document.getElementById('confirm-dialog').showModal();
    document.getElementById('confirm-dialog').style.display = 'none';
    
}

function cancelOperation() {
    document.getElementById('confirm-dialog').close();
    document.getElementById('email').value = '';
    document.getElementById('staff_id').value = '';
    document.getElementById('account_selector').value = '';
    // confirmDialog.style.display = 'none';
    document.getElementById('confirm-dialog').style.display = 'none';
    document.getElementById('email_input').style.display = 'none';
    document.getElementById('staff_input').style.display = 'none';
}
