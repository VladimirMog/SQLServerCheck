
CREATE PROCEDURE [dbo].[EndBlockHTML]
	@html NVARCHAR(MAX) OUTPUT
AS
BEGIN
   SET @html += N'</div>';
END
