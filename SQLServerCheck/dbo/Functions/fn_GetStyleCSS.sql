﻿CREATE FUNCTION [dbo].[fn_GetStyleCSS]()
RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @StyleCSS NVARCHAR(MAX);

  SET @StyleCSS = 
  N'<style>
    html {
      font-family: sans-serif;
      line-height: 1.15;
      -webkit-text-size-adjust: 100%;
      -webkit-tap-highlight-color: transparent
    }

    body {
      margin: 10;
      font-family: "Source Sans Pro",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol";
      font-size: 1rem;
      font-weight: 400;
      line-height: 1.5;
      color: #212529;
      text-align: left;
      background-color: #fff
    }

    b, strong {
      font-weight: bolder
    }

    small {
      font-size: 80%
    }

    sub, sup {
      position: relative;
      font-size: 75%;
      line-height: 0;
      vertical-align: baseline
    }

    sub {
      bottom: -.25em
    }

    sup {
      top: -.5em
    }

    table {
      border-collapse: collapse
    }

    th {
      text-align: center;
	  background-color: #eee
    }

	meter {
     width: 100%;
     height: 20px;
   }

    .table {
      width: 100%;
      margin-bottom: 1rem;
      color: #212529;
      background-color: transparent
    }

    .table td, .table th {
    padding: .75rem;
    vertical-align: top;
    border-top: 1px solid #dee2e6
    }

	.right {
		text-align: right !important;
		margin-right: 10px
	}

	.center {
		text-align: center
	}

    .table thead th {
    vertical-align: bottom;
    border-bottom: 2px solid #dee2e6
    }

    .table tbody + tbody {
    border-top: 2px solid #dee2e6
    }

    .table-bordered {
      border: 1px solid #dee2e6
    }

    .table-bordered td, .table-bordered th {
    border: 1px solid #dee2e6
    }

    .table-bordered thead td, .table-bordered thead th {
    border-bottom-width: 2px
    }

    .card {
      position: relative;
      display: -ms-flexbox;
      display: flex;
      -ms-flex-direction: column;
      flex-direction: column;
      min-width: 0;
      word-wrap: break-word;
      background-color: #fff;
      background-clip: border-box;
      border: 0 solid rgba(0,0,0,.125);
      border-radius: .25rem
    }

	.card-title {
	  position: relative;
      display: -ms-flexbox;
      display: flex;
      -ms-flex-direction: column;
      flex-direction: column;
	  text-align: center;
      margin-bottom: .75rem
    }

    .card-body {
      -ms-flex: 1 1 auto;
      flex: 1 1 auto;
      min-height: 1px;
      padding: 1.25rem
    }

    .card-header {
      padding: .75rem 1.25rem;
      margin-bottom: 0;
      background-color: #ddd;
      border-bottom: 0 solid rgba(0,0,0,.5)
    }



    .card-footer {
      padding: .75rem 1.25rem;
      background-color: rgba(0,0,0,.03);
      border-top: 0 solid rgba(0,0,0,.125)
    }

    .row {
      display: -ms-flexbox;
      display: flex;
      -ms-flex-wrap: wrap;
      flex-wrap: wrap;
      margin-right: -7.5px;
      margin-left: -7.5px
    }

	.col-1 {
		-ms-flex: 0 0 8.333333%;
		flex: 0 0 8.333333%;
		max-width: 8.333333%
    }

    .col-2 {
		-ms-flex: 0 0 16.666667%;
		flex: 0 0 16.666667%;
		max-width: 16.666667%
    }

    .col-3 {
		-ms-flex: 0 0 25%;
		flex: 0 0 25%;
		max-width: 25%
    }

    .col-4 {
		-ms-flex: 0 0 33.333333%;
		flex: 0 0 33.333333%;
		max-width: 33.333333%
    }

    .col-5 {
		-ms-flex: 0 0 41.666667%;
		flex: 0 0 41.666667%;
		max-width: 41.666667%
    }

    .col-6 {
		-ms-flex: 0 0 50%;
		flex: 0 0 50%;
		max-width: 50%
    }

    .col-7 {
		-ms-flex: 0 0 58.333333%;
		flex: 0 0 58.333333%;
		max-width: 58.333333%
    }

    .col-8 {
		-ms-flex: 0 0 66.666667%;
		flex: 0 0 66.666667%;
		max-width: 66.666667%
    }

    .col-9 {
		-ms-flex: 0 0 75%;
		flex: 0 0 75%;
		max-width: 75%
    }

    .col-10 {
		-ms-flex: 0 0 83.333333%;
		flex: 0 0 83.333333%;
		max-width: 83.333333%
    }

    .col-11 {
		-ms-flex: 0 0 91.666667%;
		flex: 0 0 91.666667%;
		max-width: 91.666667%
    }

    .col-12 {
		-ms-flex: 0 0 100%;
		flex: 0 0 100%;
		max-width: 100%
    }

  </style>';
  RETURN @StyleCSS
END
