#!/usr/bin/env zx
//
// Given a Jira issue key (e.g. SUB-8772) fetch the summary from Jira and generate a
// suitable git branch name.
// 
// USAGE Example
//
// $ ./,get-issue-branch --key SUB-8336
// SUB-8336-review-the-rest-of-existing-sysdig-security-tickets $

let Key = "SUB-8772"
if ("key" in argv) {
  Key = argv.key
} else {
  console.error("missing argument: --key")
  process.exit(1)
}


let API_token = (await $`pass Bitbucket/API-token/development`).stdout.trim()
let Response = await fetch(`https://nine.atlassian.net/rest/api/3/issue/${Key}`, {
    method: 'GET',
    headers: {
        'Authorization': `Basic ${Buffer.from(`bill.birch@nine.com.au:${API_token}`).toString('base64')}`,
        'Accept': 'application/json'
    }
})
let Body = await Response.json()
let Top = Object.getOwnPropertyNames(Body)
if (Top.includes('errorMessages') || Top.includes('errors') || !Top.includes('fields') ) {
  console.error(Body)
  process.exit(1)
}

let Summary = Body.fields.summary
process.stdout.write(`${Key}-${Summary
  .replace(/\[.*\]/g,'')
  .replace(/\(.*\)/g,'')
  .trim()
  .toLowerCase()
  .replaceAll(' ', '-')
  .replaceAll(',', '-') }`)
