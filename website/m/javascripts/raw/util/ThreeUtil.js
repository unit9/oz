/*global Package */
/*global Class */

/*global console */

Package('util',
[
	Class('public singleton ThreeUtil',
	{
		_public:
		{
			rotate : function($object, rotationX, rotationY, rotationZ)
			{
				var transform = 'rotateX(' + rotationX + 'deg) rotateY(' + rotationY + 'deg) rotateZ(' + rotationZ + 'deg)';
				$object.css('-webkit-transform', transform).css('transform', transform).css('-webkit-transform-style', 'preserve-3d');
			},

			setPosition : function($object, x, y, z)
			{
				var transform = 'translateX(' + x + 'px) translateY(' + y + 'px) translateZ(' + z + 'px)';
				$object.css('-webkit-transform', transform).css('transform', transform).css('-webkit-transform-style', 'preserve-3d');
			},

			setPerspective : function($object, perspective)
			{
				$object.parent().css('perspective', perspective).css('-webkit-perspective', perspective).css('-webkit-transform-style', 'preserve-3d');
			}
		}
	})
]);