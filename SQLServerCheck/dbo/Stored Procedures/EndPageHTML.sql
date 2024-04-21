
CREATE   PROCEDURE [dbo].[EndPageHTML]
	@html NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET @html += N'</div></section></body></html>';
END
