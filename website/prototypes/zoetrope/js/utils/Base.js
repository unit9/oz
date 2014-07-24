function Base() {}

// *	Binding Javascript Method References To Their Parent Classes
//		http://www.bennadel.com/blog/1517-Binding-Javascript-Method-References-To-Their-Parent-Classes.htm

Base.prototype.Bind = function( method )
{
	var objSelf = this;
 
	// Return a method that will call the given method
	// in the context of THIS object.
	return( function(){ return( method.apply( objSelf, arguments ) ); });
}