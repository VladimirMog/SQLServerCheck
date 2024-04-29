CREATE   PROCEDURE [dbo].[BeginPageHTML]
	@html NVARCHAR(MAX) OUTPUT,
	@title NVARCHAR(255) = ''
AS
BEGIN
	SET @html =  N'<html><head><meta charset="utf-8"/><title>' + @title + '</title>';
	SET @html += dbo.fn_GetStyleCSS();
	SET @html += N'</head><body><section><div class="container-fluid">';
END
