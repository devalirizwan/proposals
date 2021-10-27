import { Controller } from "stimulus"
import Rails from '@rails/ujs'
import toastr from 'toastr'
import Tagify from '@yaireo/tagify'

export default class extends Controller {
  static targets = [ 'toc', 'ntoc', 'templates', 'status', 'statusOptions', 'proposalStatus',
                     'organizersEmail', 'bothReviews', 'scientificReviews', 'ediReviews' ]

  connect () {
    let proposalId = 0
    if(this.hasTocTarget) {
      this.tocTarget.checked = true;
    }
    else if (this.hasOrganizersEmailTarget) {
      var inputElm = this.organizersEmailTarget,
      tagify = new Tagify (inputElm);
    }
    if(this.hasBothReviewsTarget) {
      this.bothReviewsTarget.checked = true;
    }
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
        data,
        error: (response) => {
          let errors = response.errors
          toastr.error(errors)
        }
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
          $('#birs_email_subject').val(data.email_template.subject)
          $('#birs_email_body').val(data.email_template.body)
        }
      })
    }else {
      $('#birs_email_subject').val('')
      $('#birs_email_body').val('')
    }
  }

  emailModal() {
    event.preventDefault()

    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(typeof array[1] === "undefined")
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
      array = array.slice(1)
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
          document.getElementById("proposal_booklet").click();
          toastr.success('Proposals book successfully created.')
      }).fail(function() {
        toastr.error('Something went wrong.')
      })
    }
  }

  handleStatus() {
    let currentProposalId = event.currentTarget.dataset.id
    for(var i = 0; i < this.statusOptionsTargets.length; i++){
      if(currentProposalId === this.statusOptionsTargets [`${i}`].dataset.id){
        this.proposalStatusTargets [`${i}`].classList.add("hidden")
        this.statusOptionsTargets [`${i}`].classList.remove("hidden")
      }
    }
  }

  proposalStatuses() {
    let id = event.currentTarget.dataset.id
    let status = ''
    let _this = this
    for(var i = 0; i < this.statusTargets.length; i++){
      if(id === this.statusTargets [`${i}`].dataset.id){
        status = this.statusTargets [`${i}`].value
        $.post(`/submitted_proposals/${id}/update_status?status=${status}`, function() {
          toastr.success('Proposal status has been updated!')
          setTimeout(function() {
            window.location.reload();
          }, 1000)
        })
        .fail(function() {
          toastr.error("Proposal status cannot be updated!")
        });
      }
    }
  }

  storeID() {
    this.proposalId = event.currentTarget.dataset.value
  }

  selectAllProposals() {
    let getId = ''
    $("input:checkbox").each(function(){
      getId = document.getElementById(this.id)
      getId.checked = true
    });
  }

  unselectAllProposals() {
    let getId = ''
    $("input:checkbox").each(function(){
      getId = document.getElementById(this.id)
      getId.checked = false
    });
  }

  invertSelectedProposals() {
    let checkbox = ''
    $("input:checkbox").each(function(){
      checkbox = document.getElementById(this.id)
      if(checkbox.checked) {
        checkbox.checked = false
      } else {
        checkbox.checked = true
      }
    });
  }

  downloadCSV() {
    var array = [];
    $("input:checked").each(function() {
      array.push(this.dataset.value);
    });
    if(typeof array[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      let selectedProposals = array.filter((x) => typeof x !== "undefined")
      window.location = `/submitted_proposals/download_csv.csv?ids=${selectedProposals}`
    }
  }

  importReviews() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      proposalIds = proposalIds.slice(1)
      $.post(`/submitted_proposals/import_reviews?proposals=${proposalIds}`, function(response) {
        let res = JSON.parse(response)
        if(res.type === "alert") {
          toastr.error(res.message)
        }
        else{
          toastr.success(res.message)
          setTimeout(function() {
            window.location.reload();
          }, 1000)
        }
      }).fail(function(response) {
        toastr.error(response.responseText)
      })
    }
  }

  reviewsContent() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      $("#review-window").modal('show')
    }
  }

  reviewsBooklet() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    let content = ''
    if(this.bothReviewsTarget.checked) {
      content = "both"
    }
    else if(this.scientificReviewsTarget.checked) {
      content = "scientific"
    }
    else {
      content = "edi"
    }
    this.createReviewsBooklet(content, proposalIds)
  }

  createReviewsBooklet(content, proposalIds) {
    if(content !== '') {
      proposalIds = proposalIds.slice(1)
      $.ajax({
        url: `/submitted_proposals/reviews_booklet?content=${content}`,
        type: 'POST',
        data: {
          'proposals': proposalIds
        },
        success: () => {
          document.getElementById("reviews_booklet").click();
          toastr.success('Review Booklet successfully created.')
        },
        error: () => {
          toastr.error('Something went wrong.')
        }
      })
    }
    else {
      toastr.error('Something went wrong.')
    }
  }

  removeFile(evt) {
    let dataset = evt.currentTarget.dataset
    
    $.ajax({
      url: `/reviews/${dataset.reviewId}/remove_file?attachment_id=${dataset.attachmentId}`,
      type: 'DELETE',
      data: {
        'attachment_id': dataset.attachmentId
      },
      success: () => {
        $(`#review-file${dataset.attachmentId}`).remove()
        toastr.success('Comment has successfully been removed.')
      },
      error: () => {
        toastr.error('Something went wrong.')
      }
    })
  }

  addFile(evt) {
    let dataset = evt.currentTarget.dataset
    if(evt.target.files) {
      var data = new FormData()
      var f = evt.target.files[0]
      var ext = f.name.split('.').pop();
      this.sendRequest(ext, data, f, dataset)
    }
  }

  reviewsExcelBooklet() {
    var proposalIds = [];
    $("input:checked").each(function() {
      proposalIds.push(this.dataset.value);
    });
    if(typeof proposalIds[1] === "undefined")
    {
      toastr.error("Please select any checkbox!")
    }
    else {
      proposalIds = proposalIds.slice(1)
      window.location = `/submitted_proposals/reviews_excel_booklet.xlsx?proposals=${proposalIds}`
    }
  }

  sendRequest(ext, data, f, dataset) {
    if( ext === "pdf" || ext === "txt" || ext === "text") {
      data.append("file", f)
      var url = `/reviews/${dataset.reviewId}/add_file`
      Rails.ajax({
        url,
        type: "POST",
        data,
        success: () => {
          location.reload(true)
          toastr.success('File is attached successfully.')
        },
        error: (response) => {
          toastr.error(response.errors)
        }
      })
    }
    else {
      toastr.error('Only .pdf and .txt files are allowed.')
    }
  }
}
