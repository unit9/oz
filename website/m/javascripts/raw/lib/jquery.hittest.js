(function ($)
{
	$.fn.hitTest = function (x, y, recursive)
	{
		var offset = this.offset();
		return (offset && (x > offset.left && x < offset.left + this.width()) && (y > offset.top && y < offset.top + this.height())) || (recursive && this.children().hitTest(x, y));
    };
})(jQuery);