
CREATE PROCEDURE [dbo].[BeginBlockHTML]
	@html NVARCHAR(MAX) OUTPUT
AS
BEGIN
   SET @html += N'<div class="row">';
END
