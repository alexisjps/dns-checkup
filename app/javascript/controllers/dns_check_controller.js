import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dns-check"
export default class extends Controller {
  static targets = ["domain", "table"]

  async check(event) {
    event.preventDefault()
    const domain = this.domainTarget.value
    const response = await fetch(`/dns_check/check?domain=${domain}`)
    const data = await response.json()

    console.log("CNAME records:", data.cname_records);

    const aRows = data.a_records.map(ip => {
      return `<tr><td>A</td><td>${domain}</td><td>${ip}</td></tr>`
    }).join("")

    const nsRows = data.ns_records.map(ns => {
      return `<tr><td>NS</td><td>${domain}</td><td>${ns}</td></tr>`
    }).join("")

    const cnameRows = data.cname_records.map(record => {
      const herokuConfigured = record.cname.includes("heroku");
      const iconClass = herokuConfigured ? "text-success" : "text-danger";
      const iconTitle = herokuConfigured ? "Domaine configuré pour Heroku" : "Domaine non configuré pour Heroku";
      const iconName = herokuConfigured ? "check-circle" : "times-circle";

      return `
        <tr>
          <td>CNAME</td>
          <td>${record.subdomain}.${domain}</td>
          <td>
            ${record.cname}
            <i class="fas fa-${iconName} ${iconClass}" title="${iconTitle}"></i>
          </td>
        </tr>
      `;
    }).join("")

    const mxRows = data.mx_records.map(mx => {
      return `<tr><td>MX</td><td>${domain}</td><td>${mx.priority} ${mx.exchange}</td></tr>`
    }).join("")

    const txtRows = data.txt_records.map(txt => {
      return `<tr><td>TXT</td><td>${domain}</td><td>${txt}</td></tr>`
    }).join("")

    const table = `
      <table class="table table-striped table-bordered">
        <thead>
          <tr>
            <th>Type</th>
            <th>Nom de domaine</th>
            <th>Valeur</th>
          </tr>
        </thead>
        <tbody>
          ${aRows + nsRows + cnameRows + mxRows + txtRows}
        </tbody>
      </table>
    `

    this.tableTarget.innerHTML = table
  }
}
