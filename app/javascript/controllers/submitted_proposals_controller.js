import { Controller } from "stimulus"
import Rails from '@rails/ujs'
import toastr from 'toastr'

export default class extends Controller {
  static targets = [ "toc", "ntoc", "templates" ]

  connect () {
    this.tocTarget.checked = true;
  }

  editFlow() {
    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(typeof array[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      array = array.slice(1)
      let data = new FormData()
      data.append("ids", array)
      var url = `/submitted_proposals/edit_flow`
      Rails.ajax({
        url,
        type: "POST",
        data
      })
    }
  }

  emailTemplate() {
    let value = event.currentTarget.value
    if(value) {
      let data = new FormData()
      data.append("email_template", value)
      var url = `/emails/email_template`
      Rails.ajax({
        url,
        type: "PATCH",
        data,
        success: (data) => {
          $('#subject').val(data.email_template.subject)
          $('#body').val(data.email_template.body)
        }
      })
    }else {
      $('#subject').val('')
      $('#body').val('')
    }
  }

  emailModal() {
    event.preventDefault()

    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(typeof array[0] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let id = event.currentTarget.id
      let _this = this
      $.post(`/emails/email_types?type=${id}`, function(data) {
        const selectBox = _this.templatesTarget;
        selectBox.innerHTML = '';
        const opt = document.createElement('option');
        opt.innerHTML = ''
        selectBox.appendChild(opt);
        data.email_templates.forEach((item) => {
          const opt = document.createElement('option');
          opt.innerText = item
          selectBox.appendChild(opt);
        });
        $("#email-template").modal('show')
      })
    }
  }

  sendEmails(event) {
    event.preventDefault();

    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(this.templatesTarget.value) {
      array = this.checkArray(array)
      $.post(`/submitted_proposals/approve_decline_proposals?proposal_ids=${array}`,
        $("#approve_decline_proposals").serialize(), function() {
          toastr.success("Emails have been sent!")
          setTimeout(function() {
            window.location.reload();
          }, 2000)
        }
      )
      .fail(function(response) {
        let errors = response.responseJSON
        $.each(errors, function(index, error) {
          toastr.error(error)
        })
      });
    }
    else {
      toastr.error("Please select any template")
    }
  }

  checkArray(array) {
    let length = array.length
    if(typeof array [`${length - 1}`] === "undefined" && typeof array [`${length - 2}`] === "undefined") {
      array = array.slice(0, length-2)
    }
    else if(length > 1 && typeof array [`${length - 1}`] === "undefined") {
      array = array.slice(0, length-1)
    }
    return array
  }

  tableOfContent() {
    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(typeof array[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      $.post(`/submitted_proposals/table_of_content?proposals=${array}`,
        $('form#submitted-proposal').serialize(), function(data) {
          $('#proposals').text(data.proposals)
          $("#table-window").modal('show')
        }
      )
    }
  }

  booklet() {
    let ids = $('#proposals').text().slice(1)
    let table = ''
    if(this.tocTarget.checked) {
      table = "toc"
    }
    else {
      table = "ntoc"
    }
    if(table !== '') {
      $.post(`/submitted_proposals/proposals_booklet?proposal_ids=${ids}&table=${table}`,
        function() {
          document.getElementById("booklet").click();
          window.location.reload()
      })
    }
  }
}
