/**
 * JavaScript Programmer's Object Oriented Framework
 * https://github.com/maciejzasada/poof.js
 *
 * @author Maciej Zasada / http://www.maciejzasada.com / http://www.unit9.com/reel?filter-staff-member=maciej-zasada
 * @version 0.1 (Alpha)
 * @date 10/01/2013
 * @copyright Maciej Zasada
 * @license Released under the MIT license
 */

/*global console */

(function(window, undefined)
{
	/**
	 * Public Poof interface
	 */
	var Poof = Poof ||
	{
		/**
		 * Version info
		 */
		VERSION				: 0,
		REVISION			: 1,

		/**
		 * Core variables
		 */
		undefined			: undefined,			// for easier typeof(var) === 'undefined' comparing
		debug				: false,				// enables / disables console and runtime error checking
		useRuntimeCache		: true,					// enables caching class structure information for faster operation
		importRoot			: 'javascripts/min',	// root package folder
		importSuffix		: '.min.js',			// class file suffix
		concatenated		: false,				// if true, skips class file name check and allows classes to be put in one .js file
		loadCondition		: null,					// as it is impossible to dertermine whether a non-Poof class / library has been concatenated with the code, the loadCondition function is being run each time you call Load. Returning true fires the load. Returning false skips it. Common use case is assigning function() { return !Poof.concatenated; } which will result in the Loads firing only if code is not concatenated.
		synchronousPackageInitialisation	: true,	// if true, Poof will parse entire main file until it starts initialising classes. This ensures that dependency classes that are concatenated in the main file further down are not reported missing if classes above import them.

		/**
		 * Retains current context for asynchronous callbacks.
		 *
		 * @param self context to be retained
		 * @param f funciton to be executed within the retained context
		 * @return funciton the function with context retained
		 *
		 * @example $('#myButton').bind('click', Poof.retainContext(this, this.handlerFunction));
		 */
		retainContext : function(self, f)
		{
			return function()
			{
				if(f === undefined)
				{
					return null;
				}

				return f.apply(self, arguments);
			};
		},

		/**
		 * Explicit way to inform developers that a variable is being unused on purpose
		 * and suppress linter warnings.
		 *
		 * @param pass any unused the unused variable(s) to suppress warnings for
		 * @return undefined
		 *
		 * @example Poof.suppressUnused()
		 */
		suppressUnused : function()
		{
			return;
		}
	};

	/**
	 * Compatibility fixes to old browsers.
	 */
	var compatibilityFixes =
	{
		/**
	 	* Array.indexOf() fix for IE.
	 	*/
	 	arrayIndexOf :
	 	{
	 		/*
	 		 * Applies Array.indexOf() fix for IE.
	 		 *
	 		 * @return undefined
	 		 */
	 		apply : function()
	 		{
	 			if(!Array.prototype.indexOf)
				{
					Array.prototype.indexOf = function (searchElement /*, fromIndex */)
					{
						"use strict";
						console.log('custom');
						if (this == null)
						{
							throw new TypeError();
						}

						var t = Object(this);
						var len = t.length >>> 0;
						if (len === 0)
						{
							return -1;
						}

						var n = 0;
						if(arguments.length > 1)
						{
							n = Number(arguments[1]);
							if(n != n)
							{
								n = 0;
							} else if(n != 0 && n != Infinity && n != -Infinity)
							{
								n = (n > 0 || -1) * Math.floor(Math.abs(n));
							}
						}

						if(n >= len)
						{
							return -1;
						}

						var k = n >= 0 ? n : Math.max(len - Math.abs(n), 0);
						for (; k < len; k++)
						{
							if(k in t && t[k] === searchElement)
							{
								return k;
							}
						}
						return -1;
					};
				}
	 		}
	 	},

	 	/**
	 	 * Missing console object fix for older browsers (mostly IE).
	 	 */
	 	console :
	 	{
	 		/**
			 * Applies missing console object fix for older browsers (mostly IE).
			 *
			 * @return undefined
			 */
	 		apply : function()
	 		{
	 			window.console = (Poof.debug && console) ? console : (function()
	 			{
	 				var mockConsole = {};
	 				var emptyFunction = function() {};
	 				var methods = ['assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error', 'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log', 'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd', 'timeStamp', 'trace', 'warn'];
	 				var length = methods.length;
	 				while(--length > -1)
	 				{
	 					mockConsole[methods[length]] = emptyFunction;
	 				}
	 				return mockConsole;
	 			})();
	 		}
	 	},

	 	/**
	 	 * Applies all compatibility fixes.
	 	 * @return undefined
	 	 */
	 	applyAll : function()
	 	{
	 		this.arrayIndexOf.apply();
	 		this.console.apply();
	 	}
	};

	/**
	 * Runtime utils
	 */
	var RuntimeUtils =
	{
		/**
		 * Associative array to cache methods belonging to each class (for _private and _protected scope support).
		 * TODO: debug and finish implementing _private and _protected scope. Currently they work as _public.
		 */
		classMethodsCache : {},

		/**
		 * Associative array to cache methods belonging to each package (for _internal scope support).
		 * TODO: debug and finish implementing _internal scope. Currently works as _public.
		 */
		packageMethodsCache : {},

		/**
		 * Determines if a method belongs to a given class.
		 * TODO: debug and finish implementing. Currently not working properly because of other function encapsulation.
		 *
		 * @param method function whose scope will be checked
		 * @param classObject class against which the member method should be checked for scope
		 * @return boolean true if method belongs to classObject, false otherwise
		 */
		doesMethodBelongToClass : function(method, classObject)
		{
			var classMethodsCache = RuntimeUtils.classMethodsCache;

			if(Poof.useRuntimeCache)
			{
				if(classObject._classInfo.id in classMethodsCache && method in classMethodsCache[classObject._classInfo.id])
				{
					// return from cache
					return classMethodsCache[classObject._classInfo.id][method];
				}

				// init cache
				if(!(classObject._classInfo.id in classMethodsCache))
				{
					classMethodsCache[classObject._classInfo.id] = {};
				}

				if(!(method in classMethodsCache[classObject._classInfo.id]))
				{
					classMethodsCache[classObject._classInfo.id][method] = true;
				}
			}

			// check if the function calling is defined
			if(method === undefined || classObject === undefined || method === null || classObject === null)
			{
				if(Poof.useRuntimeCache)
				{
					classMethodsCache[classObject._classInfo.id][method] = false;
				}
				return false;
			}

			// check static methods
			var keys = Object.getOwnPropertyNames(classObject);
			var i;
			for(i = 0; i < keys.length; ++i)
			{
				if(classObject[keys[i]] === method)
				{
					return true;
				}
			}

			// check instance methods
			keys = Object.getOwnPropertyNames(classObject.prototype);
			for(i = 0; i < keys.length; ++i)
			{
				if(classObject.prototype[keys[i]] === method)
				{
					return true;
				}
			}

			if(Poof.useRuntimeCache)
			{
				classMethodsCache[classObject._classInfo.id][method] = false;
			}

			return false;
		},

		/**
		 * Determines if a method belogs to any class from a given package.
		 * TODO: implement
		 *
		 * @param method method whose scope is to be checked
		 * @param packageName name of a package in which to look for a class having the specified method
		 * @return boolean true if method belongs to a class from package packageName, false otherwise
		 */
		isMethodInternalOfPackage : function(method, packageName)
		{
			// TODO: implement
		}
	};

	/**
	 * Function encapsulation mechanisms according to function scope.
	 */
	var Scope =
	{
		/**
		 * Encapsulation mechanisms for static members.
		 */
		scopeClass:
		{
			/**
			 * Encapsulation mechanisms for static variables.
			 */
			field:
			{
				/**
				 * Encapsulates a variable into a public static variable.
				 * TODO: review expected outcome and implement. For now it returns the original field.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_public_static : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				},

				/**
				 * Encapsulates a variable into an internal static variable.
				 * TODO: review expected outcome and implement. For now it returns the original field.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_internal_static : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				},

				/**
				 * Encapsulates a variable into a public private variable.
				 * TODO: review expected outcome and implement. For now it returns the original field.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_private_static : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				}
			},

			/**
			 * Encapsulation mechanisms for static methods
			 */
			method:
			{
				/**
				 * Encapsulates a method into a public static method.
				 * TODO: review expected outcome and implement. For now it returns the original field.
				 *
				 * @param name name of the method
				 * @param m the method
				 * @param self object to which the method belongs
				 * @return function the encapsulated method
				 */
				_public_static : function(name, m, self)
				{
					Poof.suppressUnused(name, self);
					return m;
				},

				/**
				 * Encapsulates a method into an internal static method.
				 * TODO: review expected outcome and implement. For now it returns the original field.
				 *
				 * @param name name of the method
				 * @param m the method
				 * @param self object to which the method belongs
				 * @return function the encapsulated method
				 */
				_internal_static : function(name, m, self)
				{
					Poof.suppressUnused(name, self);
					return m;
				},

				/**
				 * Encapsulates a method into a private static method.
				 * TODO: debug and make sure it works correct. Possible bugs.
				 *
				 * @param name name of the method
				 * @param m the method
				 * @param self object to which the method belongs
				 * @return function the encapsulated method
				 */
				_private_static : function(name, m, self)
				{
					Poof.suppressUnused(self);

					var privateMethod = function()
					{
						var ownClass = this;
						var callingFunction = privateMethod.caller;
						if(RuntimeUtils.doesMethodBelongToClass(callingFunction, ownClass))
						{
							return m.apply(this, arguments);
						} else
						{
							err('illegal attempt to call a private static method \'' + name + '\' on \'' + ownClass._classInfo.name + '\' from outside the class');
							return null;
						}
					};

					return privateMethod;
				}
			},

			/**
			 * Encapsulation mechanisms for different types of classes.
			 */
			classType:
			{
				/**
				 * Performs any needed encapsulation actions for a normal type class.
				 * Currently there are no needed actions for this type of class.
				 *
				 * @param classObject the class object to be encapsulated
				 * @return undefined
				 */
				normal : function(classObject)
				{
					Poof.suppressUnused(classObject);
					return;
				},

				/**
				 * Performs any needed encapsulation actions for an abstract type class.
				 * Currently there are no needed actions for this type of class.
				 * Actual encapsulation of abstract classes is limited to constructor encapsulation.
				 *
				 * @param classObject the class object to be encapsulated
				 * @return undefined
				 */
				abstract : function(classObject)
				{
					Poof.suppressUnused(classObject);
					return;
				},

				/**
				 * Performs any needed encapsulation actions for a singleton type class.
				 * Adds a static getInstance() method to the class object.
				 *
				 * @param classObject the class object to be encapsulated
				 * @return undefined
				 */
				singleton : function(classObject)
				{
					/**
					 * Returns a singleton instance of a class
					 *
					 * @return class singleton instance of a class
					 */
					classObject.getInstance = function()
					{
						return InternalClassUtils.getSingletonInstanceOfClass(classObject);
					};
				}
			}
		},

		/**
		 * Encapsulation mechanisms for instance members
		 */
		scopeInstance:
		{
			/**
			 * Constructor encapsulation mechanisms
			 */
			constructor:
			{
				/**
				 * Encapsulates constructor of a normal type class.
				 * The encapsulated constructor creates a member _instanceInfo object containing the instance's ID (_instanceInfo.id).
				 * Each instance of a given class has a different ID then. IDs are being assigned starting from 0.
				 *
				 * @param name name of the method (constructor)
				 * @param c the constructor function
				 * @param self object to which the constructor belongs
				 * @return function the encapsulated constructor method
				 */
				normal : function(name, c, self)
				{
					Poof.suppressUnused(self);

					var constructor = function()
					{
						this._instanceInfo =
						{
							id: InternalClassUtils.getNextClassInstanceId(this._class)
						};
						c.apply(this, arguments);
					};

					return constructor;
				},

				/**
				 * Encapsulates constructor of a abstract type class.
				 * As abstract classes cannot be instantiated directly, this method overrides the constructor completely.
				 * The overridden constructor logs an error about illegal attempt to instantiate an abstract class.
				 *
				 * @param name name of the method (constructor)
				 * @param c the constructor function
				 * @param self object to which the constructor belongs
				 * @return function the encapsulated constructor method
				 */
				abstract : function(name, c, self)
				{
					Poof.suppressUnused(c, self);

					var constructor = function()
					{
						err('illegal attempt to instantiate an abstract class ' + this._class + '. Abstract classes can only be extended.', true);
					};

					return constructor;
				},

				/**
				 * Encapsulates constructor of a singleton type class.
				 * Singleton classes cannot be instantiated direclty; they can only be instantiated inside the class's getInstance() method.
				 * The encapsulated constructor checks if the instantiation call comes from within the class's getInstance() method.
				 * If yes, it first retrieves an encapsulated constructor of a normal type of this class, then, runs the encapsulated constructor.
				 * Otherwise, an error about illegal attempt to directly instantiate a singleton class is being logged.
				 *
				 * @param name name of the method (constructor)
				 * @param c the constructor function
				 * @param self object to which the constructor belongs
				 * @return function the encapsulated constructor method
				 */
				singleton : function(name, c, self)
				{
					Poof.suppressUnused(self);

					var constructor = function()
					{
						if(InternalClassUtils.singletonConstructor)
						{
							c = Scope.scopeInstance.constructor.normal(name, c);
							c.apply(this, arguments);
						} else
						{
							err('illegal attempt to directly instantiate a singleton class ' + this._class + '. Please use ' + name + '.getInstance() instead.', true);
						}
					};

					return constructor;
				},

				/**
				 * Encapsulates constructor of a subclass (when extension takes place).
				 * The encapsulated constructor exposes a _super variable and assigns the superclass's constructor to it so it can be called from within the subclass's constructor.
				 *
				 * @param name name of the method (constructor)
				 * @param baseConstructor the superclass's constructor function
				 * @param extendedConstructor the subclass's constructor function
				 * @return function the overridden constructor method
				 */
				override : function(name, baseConstructor, extendedConstructor)
				{
					Poof.suppressUnused(name);

					var encapsulatedConstructor = function()
					{
						this._super = baseConstructor;
						extendedConstructor.apply(this, arguments);
					};

					return encapsulatedConstructor;
				}
			},

			/**
			 * Member field encapsulation mechanisms
			 */
			field:
			{
				/**
				 * Encapsulates a field into a public field.
				 * Currently this implies returning the original value of that field.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_public : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				},

				/**
				 * Encapsulates a field into a protected field.
				 * Currently the original field value is being returned.
				 * TODO: review expected outcome and implement. Suggested approach is to convert into a pair of getter and setter functions that will check for correct scope.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_protected : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				},

				/**
				 * Encapsulates a field into an internal field.
				 * Currently the original field value is being returned.
				 * TODO: review expected outcome and implement. Suggested approach is to convert into a pair of getter and setter functions that will check for correct scope.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_internal : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				},

				/**
				 * Encapsulates a field into a private field.
				 * Currently the original field value is being returned.
				 * TODO: review expected outcome and implement. Suggested approach is to convert into a pair of getter and setter functions that will check for correct scope.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_private : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				},

				/**
				 * Encapsulates a field into a public final (constant) field.
				 * Currently the original field value is being returned.
				 * TODO: review expected outcome and implement. Suggested approach is to convert into a function (a getter) that will check for correct scope.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_public_final : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				},

				/**
				 * Encapsulates a field into a protected final (constant) field.
				 * Currently the original field value is being returned.
				 * TODO: review expected outcome and implement. Suggested approach is to convert into a function (a getter) that will check for correct scope.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_protected_final : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				},

				/**
				 * Encapsulates a field into an internal final (constant) field.
				 * Currently the original field value is being returned.
				 * TODO: review expected outcome and implement. Suggested approach is to convert into a function (a getter) that will check for correct scope.
				 *
				 * @param name name of the field
				 * @param f value of the field
				 * @param self object to which the field belongs
				 * @return object the encapsulated field value
				 */
				_internal_final : function(name, f, self)
				{
					Poof.suppressUnused(name, self);
					return f;
				}
			},

			/**
			 * Member function encapsulation mechanisms
			 */
			method:
			{
				/**
				 * Encapsulates a member method into a public member method.
				 * The encapsulated constructor has correct argument count (to still enable checking for correct function overriding).
				 *
				 * @param name name of the method
				 * @param m the method
				 * @param self object to which the method belongs
				 * @return function the encapsulated method
				 */
				_public : function(name, m, self)
				{
					return InternalClassUtils.getFunctionWithArgumentsCount(function()
					{
						this._this = self;
						return m.apply(this, arguments);
					}, InternalClassUtils.getNumFunctionArguments(m));
				},

				/**
				 * Encapsulates a member method into a protected member method.
				 * The encapsulated constructor first obtains an encapsulated version of the public method.
				 * TODO: implement. Currently it return the encapsulated public member method,
				 *
				 * @param name name of the method
				 * @param m the method
				 * @param self object to which the method belongs
				 * @return function the encapsulated method
				 */
				_protected : function(name, m, self)
				{
					Poof.suppressUnused(self);

					var wrappedMethod = Scope.scopeInstance.method._public(name, m);
					return wrappedMethod;
				},

				/**
				 * Encapsulates a member method into an internal member method.
				 * The encapsulated constructor first obtains an encapsulated version of the public method.
				 * TODO: implement. Currently it return the encapsulated public member method,
				 *
				 * @param name name of the method
				 * @param m the method
				 * @param self object to which the method belongs
				 * @return function the encapsulated method
				 */
				_internal : function(name, m, self)
				{
					Poof.suppressUnused(self);

					var wrappedMethod = Scope.scopeInstance.method._public(name, m);
					return wrappedMethod;
				},

				/**
				 * Encapsulates a member method into a private member method.
				 * The encapsulated constructor first obtains an encapsulated version of the public method.
				 * Next, it determines its own class and checks whether the calling method belongs to it.
				 * If yes, it returns the result of the encapsulated public method.
				 * Otherwise, it logs an appropriate erorr message.
				 *
				 * @param name name of the method
				 * @param m the method
				 * @param self object to which the method belongs
				 * @return function the encapsulated method
				 */
				_private : function(name, m, self)
				{
					Poof.suppressUnused(self);

					var wrappedMethod = Scope.scopeInstance.method._public(name, m);

					var privateMethod = function()
					{
						var ownClass = this._class;
						var callingFunction = privateMethod.caller;
						if(RuntimeUtils.doesMethodBelongToClass(callingFunction, ownClass))
						{
							return wrappedMethod.apply(this, arguments);
						} else
						{
							err('illegal attempt to call a private method \'' + name + '\' on ' + this.toString() + ' from outside the class');
							return null;
						}
					};
					return privateMethod;
				},

				/**
				 * Encapsulates a member method when transcribing it from one instance to another.
				 * Currently this implies no additional action to be taken.
				 *
				 * @param name name of the method being transcribed
				 * @param baseMethod the method of the superclass instance
				 * @param selfObject the instance to which the method is being transcribed
				 * @return function the encapsulated function
				 */
				transcribe : function(name, baseMethod, selfObject)
				{
					Poof.suppressUnused(name, selfObject);
					return baseMethod;
				},

				/**
				 * Encapsulates a member method when overriding it (during extension).
				 * The encapsulated method exposes a _super variable and assigns the superclass's method to it so it can be called from within the subclass's method.
				 *
				 * @param name name of the method
				 * @param baseMethod the superclass's method
				 * @param extendedMethod the subclass's method
				 * @return function the overridden method
				 */
				override : function(name, baseMethod, extendedMethod)
				{
					return InternalClassUtils.getFunctionWithArgumentsCount(function()
					{
						this._super = baseMethod;
						return extendedMethod.apply(this, arguments);
					}, InternalClassUtils.getNumFunctionArguments(extendedMethod));
				}
			}
		}
	};

	/**
	 * Class model
	 * Defines the model (template) used to define a class.
	 */
	var CLASS_MODEL =
	{
		/**
		 * An ordered sequence of semantic types of keywords appearing in string-based class declarations.
		 */
		declarationFields					: ['scope', 'extendable', 'type', 'name', 'extend', 'implement'],

		/**
		 * Type constraints for object-based class declarations.
		 */
		declarationFieldsTypeConstraints:
		{
			scope:		['string'],
			extendable:	['string'],
			type:		['string', 'object'],
			name:		['string'],
			extend:		['string', 'object'],
			implement:	['string', 'object']
		},

		/**
		 * Allowed values for each semantic keyword type.
		 */
		definitionFields:
		{
			scope:					['public', 'internal'],
			extendable:				['dynamic', 'final'],
			type:					['abstract', 'singleton'],
			extend:					['extends'],
			implement:				['implements'],

			scopeClass:				['_public_static', '_internal_static', '_private_static', '_public_static_readonly', '_internal_static_readonly', '_private_static_readonly'],
			scopeInstance:			['_public', '_protected', '_internal', '_private', '_public_final', '_protected_final', '_internal_final', '_public_readonly', '_protected_readonly', '_internal_readonly', '_private_readonly']
		},

		/**
		 * Object that provides encapsulation mechanisms for scoping.
		 */
		scopingClass : Scope,

		/**
		 * The path to which a scoped object should be assigned.
		 * '' implies the root of the object.
		 */
		scopeTargetHolders:
		{
			_public_static:				'',
			_internal_static:			'',
			_private_static:			'',
			_public_static_readonly:	'',
			_internal_static_readonly:	'',
			_private_static_readonly:	'',

			_public:					'',
			_protected:					'',
			_internal:					'',
			_private:					'',
			_public_final:				'',
			_internal_final:			'',
			_protected_final:			'',
			_public_readonly:			'',
			_internal_readonly:			'',
			_protected_readonly:		'',
			_private_readonly:			''
		},

		/**
		 * List of fields and methods that should not be transcribed from class to class during extension.
		 */
		extensionDisabled:
		[
			'_class',
			'_handlers',
			'constructor',
			'toString'
		],

		/**
		 * List of class scopes that provide extension.
		 */
		inheritScope:
		[
			'_public',
			'_protected',
			'_internal'
		],

		/**
		 * Names of methods to be called in order to determine if extension of a given class by a given class is allowed.
		 */
		inheritConditions:
		{
			_public: 'inheritConditionPublic',
			_protected: 'inheritConditionPublic',
			_internal: 'inheritConditionInternal'
		},

		/**
		 * Defines in what scope to look for a constructor.
		 */
		constructorScope : '_public',

		/**
		 * Separator used to separate semantically different parts of class declaration.
		 */
		declarationSeparatorRegexp : new RegExp('[ ,]')
	};

	/**
	 * Poof base object class providing core features like events or logging.
	 */
	var PObject = function()
	{
		/**
		 * Associative array of event handlers.
		 */
		this._handlers = {};

		/**
		 * Returns a string identifier of class instance, including the instance's unique ID (unique within its class only).
		 *
		 * @return string identifier of class instance
		 */
		this.toString = function()
		{
			return '[Object ' + this._class._classInfo.qualifiedName + ' (@' + this._instanceInfo.id + ')]';
		};

		/**
		 * Provides a modified log() function to each instance for easy log source tracking.
		 * The logged message contains the identifier (toString()) of the instance logging that message.
		 *
		 * @param pass any object(s) to be logged to the console
		 */
		this.log = function()
		{
			console.log(this.toString(), arguments);
		};

		/**
		 * Adds event listener to the instance.
		 * TODO: introduce scopes (i.e. instance.on('click.scope1')) to be able to off() only one particular handler (or a group of them).
		 *
		 * @param eventName name of the event to listen for
		 * @param handler the function to be called when the event fires
		 */
		this.on = function(eventName, handler)
		{
			if(!(eventName in this._handlers))
			{
				this._handlers[eventName] = [];
			}

			this._handlers[eventName].push(handler);

			return handler;
		};

		/**
		 * Removes event listeners of a given event name from the instance.
		 * TODO: introduce scopes (i.e. instance.off('click.scope1')) to be able to off() only one particular handler (or a group of them).
		 *
		 * @param eventName name of the event to stop listening for
		 * @param handler (optional) the particular handler function to be unbinded. If nothing passed, all handler functions will be unbinded.
		 */
		this.off = function(eventName, handler)
		{
			var i;
			var keys = Object.getOwnPropertyNames(this._handlers);

			if(typeof(handler) === 'function')
			{
				for(i = 0; i < keys.length; ++i)
				{
					if(keys[i].indexOf(eventName) !== -1)
					{
						this._handlers[keys[i]].splice(this._handlers[keys[i]].indexOf(handler), 1);
					}
				}
			} else
			{
				for(i = 0; i < keys.length; ++i)
				{
					if(keys[i].indexOf(eventName) !== -1)
					{
						this._handlers[keys[i]] = [];
					}
				}
			}
		};

		/**
		 * Dispatches an event.
		 * TODO: once scopes are introduced, make it work with scopes
		 *
		 * @param eventName name of the event to be dispatched
		 * @param data (optional) the data to be attached to that event
		 */
		this.dispatch = function(eventName, data)
		{
			var eventObject =
			{
				_propagationStopped : false,
				target : this,
				type : eventName,
				data : data,
				preventDefault : function() {},
				stopPropagation : function()
				{
					eventObject._propagationStopped = true;
				}
			};

			var keys = Object.getOwnPropertyNames(this._handlers);
			for(var i = 0; i < keys.length; ++i)
			{
				if(keys[i].indexOf(eventName) !== -1)
				{
					for(var j = 0; j < this._handlers[keys[i]].length; ++j)
					{
						if(typeof(this._handlers[keys[i]][j]) === 'function')
						{
							this._handlers[keys[i]][j](eventObject);
							if(eventObject._propagationStopped)
							{
								return;
							}
						}
					}
				}
			}
		};
	};

	/**
	 * Class utilities for Poof internal use.
	 */
	var InternalClassUtils =
	{
		/**
		 * Unique class identifier.
		 */
		classId					: 0,

		/**
		 * Associative array of last used instance identifiers by class.
		 */
		classInstanceId			: {},

		/**
		 * Array of already loaded classes to ignore further imports of such class.
		 */
		loadedClasses			: [],

		/**
		 * Array of class names for which an Import() was called.
		 * This is to enable checking for correct class file name and path compared to the class package and name claimed in its declaration.
		 */
		expectedClasses			: [],

		/**
		 * Associative array of all listeners waiting for a given class to finish initialisation.
		 */
		classReadyListeners		: {},

		/**
		 * Associative array of singleton class instances by class.
		 */
		singletonInstances		: {},

		/**
		 * Flag determining whether singleton class can be instantiated at the time of checking.
		 * This flag is being temporarly set to true by getInstance() methods just before calling a singleton class's constructor
		 * and is being reset to false right after the constructor returns.
		 */
		singletonConstructor	: false,

		/**
		 * A queue of all Package objects pending initialisation.
		 * This queue comes into play when code is concatenated and Poof.synchronousPackageInitialisation is set to true.
		 */
		packagesQueue			: [],

		/**
		 * A flag determining whether some package is being currently initialised.
		 * If true, it stops any further packages from initialisation and adds them to packagesQueue.
		 */
		packageCreationInProgress	: false,

		/**
		 * Time by which each Import() execution should be delayed.
		 * The delay is important when code is concatenated as a class whose import was requested
		 * may already be further down in the concatenated file. So the file is let finish parsing
		 * and only then, if the class is still not found, the Import is actually executed.
		 * The delay is only being applied if Poof.concatenated is true.
		 */
		delayedImportTimeout	: 1,

		/**
		 * Adds Package object to initialisation queue.
		 *
		 * @param creatorFunction package initialisation function
		 * @return undefined
		 */
		queuePackageCreation : function(creatorFunction)
		{
			InternalClassUtils.packagesQueue.push(creatorFunction);
		},

		/**
		 * Picks next package from packagesQueue and initialises it.
		 *
		 * @return undefined
		 */
		createNextPackage : function()
		{
			if(InternalClassUtils.packageCreationInProgress && Poof.synchronousPackageInitialisation)
			{
				return;
			}

			if(InternalClassUtils.packagesQueue.length !== 0)
			{
				InternalClassUtils.packageCreationInProgress = true;
				(InternalClassUtils.packagesQueue.shift())();
			}
		},

		/**
		 * Gets called when a package finishes its initialisation.
		 * Triggers initialisation of a next, queued package.
		 *
		 * @return undefined
		 */
		onPackageCreationComplete : function()
		{
			InternalClassUtils.packageCreationInProgress = false;
			InternalClassUtils.createNextPackage();
		},

		/**
		 * Parses class declaration.
		 *
		 * @param declaration Class declaration object (string or object)
		 * @return object parsed declaration info object
		 */
		parseDeclaration : function(declaration)
		{
			var declarationInfo = null;

			if(declaration === undefined || declaration === null)
			{
				declarationInfo = null;
			} else if(typeof(declaration) === 'string' && declaration.length !== 0)
			{
				declarationInfo = InternalClassUtils.parseStringDeclaration(declaration);
			} else if(typeof(declaration) === 'object' && declaration !== null)
			{
				declarationInfo = InternalClassUtils.parseObjectDeclaration(declaration);
			}

			return declarationInfo;
		},

		/**
		 * Parses string-based declaration of a Class
		 *
		 * @param declaration string-based declaration of a Class
		 * @return parsed declaration info object
		 */
		parseStringDeclaration : function(declaration)
		{
			var info = {};
			for(var i = 0; i < CLASS_MODEL.declarationFields.length; ++i)
			{
				info[CLASS_MODEL.declarationFields[i]] = null;
			}

			var declarationComponents = declaration.split(' ');
			var lastIndex = 0;

			if(lastIndex < declarationComponents.length && CLASS_MODEL.definitionFields.scope.indexOf(declarationComponents[lastIndex]) !== -1)
			{
				info.scope = declarationComponents[lastIndex];
				lastIndex ++;
			} else
			{
				info.scope = '_public';
			}

			if(lastIndex < declarationComponents.length && CLASS_MODEL.definitionFields.extendable.indexOf(declarationComponents[lastIndex]) !== -1)
			{
				info.extendable = declarationComponents[lastIndex];
				lastIndex ++;
			} else
			{
				info.extendable = 'dynamic';
			}

			if(lastIndex < declarationComponents.length && CLASS_MODEL.definitionFields.type.indexOf(declarationComponents[lastIndex]) !== -1)
			{
				info.type = declarationComponents[lastIndex];
				lastIndex ++;
			}

			if(lastIndex < declarationComponents.length)
			{
				info.name = declarationComponents[lastIndex];
				lastIndex ++;
			}

			if(lastIndex < declarationComponents.length - 1 && CLASS_MODEL.definitionFields.extend.indexOf(declarationComponents[lastIndex]) !== -1)
			{
				info.extend = declarationComponents[lastIndex + 1];
				lastIndex += 2;
			}

			if(lastIndex < declarationComponents.length - 1 && CLASS_MODEL.definitionFields.implement.indexOf(declarationComponents[lastIndex]) !== -1)
			{
				info.implement = [];
				for(i = lastIndex + 1; i < declarationComponents.length; ++i)
				{
					info.implement.push(declarationComponents[i].replace(',', ''));
				}
			}

			return info;
		},

		/**
		 * Parses object-based declaration of a Class
		 *
		 * @param declaration object-based declaration of a Class
		 * @return parsed declaration info object
		 */
		parseObjectDeclaration : function(declaration)
		{
			var info = {};
			for(var i = 0; i < CLASS_MODEL.declarationFields.length; ++i)
			{
				info[CLASS_MODEL.declarationFields[i]] = declaration[CLASS_MODEL.declarationFields[i]] === undefined ? null : declaration[CLASS_MODEL.declarationFields[i]];
				if(!(CLASS_MODEL.declarationFields[i] in CLASS_MODEL.declarationFieldsTypeConstraints) || CLASS_MODEL.declarationFieldsTypeConstraints[CLASS_MODEL.declarationFields[i]].indexOf(typeof(info[CLASS_MODEL.declarationFields[i]])) === -1)
				{
					info[CLASS_MODEL.declarationFields[i]] = null;
				}
			}
			return info;
		},

		/**
		 * Parses Class definition
		 *
		 * @param definition Class definition object
		 * @return class info object
		 */
		parseDefinition : function(definition)
		{
			var info = {};

			for(var i = 0; i < CLASS_MODEL.definitionFields.scopeClass.length; ++i)
			{
				info[CLASS_MODEL.definitionFields.scopeClass[i]] = definition[CLASS_MODEL.definitionFields.scopeClass[i]] === undefined ? {} : definition[CLASS_MODEL.definitionFields.scopeClass[i]];
			}

			for(i = 0; i < CLASS_MODEL.definitionFields.scopeInstance.length; ++i)
			{
				info[CLASS_MODEL.definitionFields.scopeInstance[i]] = definition[CLASS_MODEL.definitionFields.scopeInstance[i]] === undefined ? {} : definition[CLASS_MODEL.definitionFields.scopeInstance[i]];
			}
			return info;
		},

		/**
		 * Returns an encapsulated function whose native arguments count is equal to specified
		 * to ensure argument number counting remains possible after other encapsulation.
		 * Maximum number of arguments supported is 10.
		 * TODO: think of implementation that doesn't require hardcoding and works with any number of arguments.
		 *
		 * @param func function to be encapsulated
		 * @param argumentsCount the number of arguments that the encapsulated function should natively have
		 */
		getFunctionWithArgumentsCount : function(func, argumentsCount)
		{
			var wrappedFunction;

			if(argumentsCount === 0)
			{
				wrappedFunction = function() { return func.apply(this, arguments); };
			} else if(argumentsCount === 1)
			{
				wrappedFunction = function(arg1) { Poof.suppressUnused(arg1); return func.apply(this, arguments); };
			} else if(argumentsCount === 2)
			{
				wrappedFunction = function(arg1, arg2) { Poof.suppressUnused(arg1, arg2); return func.apply(this, arguments); };
			} else if(argumentsCount === 3)
			{
				wrappedFunction = function(arg1, arg2, arg3) { Poof.suppressUnused(arg1, arg2, arg3); return func.apply(this, arguments); };
			} else if(argumentsCount === 4)
			{
				wrappedFunction = function(arg1, arg2, arg3, arg4) { Poof.suppressUnused(arg1, arg2, arg3, arg4); return func.apply(this, arguments); };
			} else if(argumentsCount === 5)
			{
				wrappedFunction = function(arg1, arg2, arg3, arg4, arg5) { Poof.suppressUnused(arg1, arg2, arg3, arg4, arg5); return func.apply(this, arguments); };
			} else if(argumentsCount === 6)
			{
				wrappedFunction = function(arg1, arg2, arg3, arg4, arg5, arg6) { Poof.suppressUnused(arg1, arg2, arg3, arg4, arg5, arg6); return func.apply(this, arguments); };
			} else if(argumentsCount === 7)
			{
				wrappedFunction = function(arg1, arg2, arg3, arg4, arg5, arg6, arg7) { Poof.suppressUnused(arg1, arg2, arg3, arg4, arg5, arg6, arg7); return func.apply(this, arguments); };
			} else if(argumentsCount === 8)
			{
				wrappedFunction = function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) { Poof.suppressUnused(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8); return func.apply(this, arguments); };
			} else if(argumentsCount === 9)
			{
				wrappedFunction = function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) { Poof.suppressUnused(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9); return func.apply(this, arguments); };
			} else if(argumentsCount === 10)
			{
				wrappedFunction = function(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) { Poof.suppressUnused(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10); return func.apply(this, arguments); };
			} else
			{
				wrappedFunction = function() { func.apply(this, arguments); };
			}

			return wrappedFunction;
		},

		/**
		 * Extends a Class
		 *
		 * @param to subclass object
		 * @param from superclass object
		 * @return undefined
		 */
		extend : function(to, from)
		{
			var keys = Object.getOwnPropertyNames(from);
			for(var i = 0; i < keys.length; ++i)
			{
				to[keys[i]] = from[keys[i]];
			}
		},

		/**
		 * Transcribes fields and methods from a particular scope from base class to extended class.
		 *
		 * @param from superclass object
		 * @param to subclass object
		 * @param type 'scopeClass' or 'scopeInstance'
		 * @param scope the scope at which the transcription should be carried (e.g. '_public')
		 * @param ignore array of fields and methods that should not be transcribed
		 * @return undefined
		 */
		transcribeScope : function(from, to, type, scope, ignore)
		{
			var scopeTargetHolder;
			var scopingMethod;
			var scopeInfoHolder = type === 'scopeClass' ? to._classInfo.scope : to._class._classInfo.scope;

			var keys = Object.getOwnPropertyNames(from);

			for(var i = 0; i < keys.length; ++i)
			{
				if(ignore === undefined || ignore.indexOf(keys[i]) === -1)
				{
					scopeTargetHolder = CLASS_MODEL.scopeTargetHolders[scope];
					if(typeof(from[keys[i]]) === 'function')
					{
						scopingMethod = InternalClassUtils.getScopedMethod;
					} else
					{
						scopingMethod = InternalClassUtils.getScopedField;
					}

					if(scopeTargetHolder === '')
					{
						to[keys[i]] = scopingMethod(keys[i], from[keys[i]], type, scope, to);
					} else
					{
						if(!(scopeTargetHolder in to))
						{
							to[scopeTargetHolder] = {};
						}
						to[scopeTargetHolder][keys[i]] = scopingMethod(keys[i], from[keys[i]], type, scope);
					}

					scopeInfoHolder[keys[i]] = scope;
				}
			}
		},

		/**
		 * Apply type to a class (e.g. singleton).
		 *
		 * @param classObject Class to which the type should be applied.
		 * @param type type that should be applied to the Class
		 * @return undefined
		 */
		typeClass : function(classObject, type)
		{
			classObject._classInfo.type = type;
			Scope.scopeClass.classType[type](classObject);
		},

		/**
		 * Returns an encapsulated constructor function for a given scope.
		 *
		 * @param name name of the constructor function (and the class)
		 * @param f constructor function
		 * @param scope scope that should be applied (e.g. '_public')
		 * @return function encapsulated function for the given scope
		 */
		getScopedConstructor : function(name, f, scope)
		{
			return Scope.scopeInstance.constructor[scope](name, f);
		},

		/**
		 * Returns an encapsulated field for a given scope.
		 *
		 * @param name name of the field to be scoped
		 * @param f field value
		 * @param scope scope that should be applied (e.g. '_public')
		 * @param self object to which the field belongs
		 * @return function encapsulated function for the given scope
		 */
		getScopedField : function(name, f, type, scope, self)
		{
			return Scope[type].field[scope](name, f, self);
		},

		/**
		 * Returns an encapsulated method for a given scope.
		 *
		 * @param name name of the method to be scoped
		 * @param m method to be scoped
		 * @param type type of the scope ('scopeInstance' or 'scopeClass')
		 * @param scope scope that should be applied (e.g. '_public')
		 * @param self object to which the field belongs
		 * @return function encapsulated method for the given scope
		 */
		getScopedMethod : function(name, m, type, scope, self)
		{
			return Scope[type].method[scope](name, m, self);
		},

		/**
		 * Returns Class object given its qualified name.
		 *
		 * @param qualifiedClassName qualified name of the class to be retrieved
		 * @return class Class object
		 */
		getClassNameFromQualifiedName : function(qualifiedClassName)
		{
			return qualifiedClassName.substring(qualifiedClassName.lastIndexOf('.') + 1, qualifiedClassName.length);
		},

		/**
		 * Returns class object (or an array of classes) of a specified name.
		 * To reduce ambiguity, if a list of classes imported in the same package is passed,
		 * the class is being searched amongst them first.
		 *
		 * @param className string name of the class to be retrieved.
		 * @param imports array of class names among which to search first
		 */
		getClassByName : function(className, imports)
		{
			var i;
			if(className in window)
			{
				if(InternalClassUtils.isArray(window[className]) && imports !== undefined)
				{
					// search within imports only
					var matches = [];
					for(i = 0; i < imports.length; ++i)
					{
						if(imports[i]._importInfo.className === className)
						{
							matches.push(imports[i]._importInfo.packageName + '.' + imports[i]._importInfo.className);
						}
					}

					if(matches.length === 1)
					{
						return InternalClassUtils.getClassByName(matches[0]);
					} else
					{
						return InternalClassUtils.getClassByName(className);
					}
				} else if(window[className] !== undefined && '_classInfo' in window[className])
				{
					return window[className];
				} else
				{
					return null;
				}
			} else if(className.indexOf('.') !== -1)
			{
				var packageComponents = className.split('.');

				var packageObject = window.Package;
				for(i = 0; i < packageComponents.length - 1; ++i)
				{
					if(!(packageComponents[i] in packageObject))
					{
						return null;
					}
					packageObject = packageObject[packageComponents[i]];
				}

				var simpleClassName = packageComponents[packageComponents.length - 1];

				if(!(simpleClassName in window))
				{
					return null;
				}

				if('_classesByName' in packageObject && simpleClassName in packageObject._classesByName)
				{
					return packageObject._classesByName[simpleClassName];
				}
			}

			return null;
		},

		/**
		 * Resolves Class's qualified name to physical .js class file location.
		 *
		 * @param qualifiedClassName qualified name of the class
		 * @return string path to the class's .js file
		 */
		getClassFileUrlFromQualifiedName : function(qualifiedClassName)
		{
			if(qualifiedClassName.indexOf('default.') === 0)
			{
				qualifiedClassName = qualifiedClassName.replace('default.', '');
			}

			var fileName = qualifiedClassName.replace('.', '/');
			while(fileName.indexOf('.') !== -1)
			{
				fileName = fileName.replace('.', '/');
			}
			return Poof.importRoot + fileName + Poof.importSuffix;
		},

		/**
		 * Returns next ID that should be assigned to a class instance.
		 *
		 * @param classObject the class object for which ID is needed
		 * @return int instance identifier (unique within its class only, starts counting from 0)
		 */
		getNextClassInstanceId : function(classObject)
		{
			return classObject in InternalClassUtils.classInstanceId ? InternalClassUtils.classInstanceId[classObject] ++ : 0;
		},

		/**
		 * Returns singleton instance of a given class.
		 * If no instance is created yet, it is being instantiated.
		 *
		 * @param classObject the class object for which a singleton instance should be obtained
		 * @return object singleton instance of the given class
		 */
		getSingletonInstanceOfClass : function(classObject)
		{
			if(!(classObject in InternalClassUtils.singletonInstances))
			{
				InternalClassUtils.singletonConstructor = true;
				InternalClassUtils.singletonInstances[classObject] = new classObject();
				InternalClassUtils.singletonConstructor = false;
			}
			return InternalClassUtils.singletonInstances[classObject];
		},

		/**
		 * Determines whether object is of Array type
		 *
		 * @param object the object whose type shall be checked
		 * @return boolean true if object is of Array type, false otherwise
		 */
		isArray : function(object)
		{
			return Object.prototype.toString.call(object) === '[object Array]';
		},

		/**
		 * Performs batch loading of external .js files.
		 *
		 * @param loads array of Load objects that should be executed
		 * @param handler function to be executed once the whole batch is loaded
		 * @return undefined
		 */
		loadBatch : function(loads, handler)
		{
			if(loads === undefined || loads.length === 0)
			{
				handler();
				return;
			}

			var loadsLeft = loads.length;

			var wrappedHandler = function()
			{
				if(-- loadsLeft === 0)
				{
					handler();
				} else
				{
					if(loads[loads.length - loadsLeft] !== undefined)
					{
						loads[loads.length - loadsLeft].execute(wrappedHandler);
					}
				}
			};

			loads[0].execute(wrappedHandler);
		},

		/**
		 * Applies inheritance between classes.
		 * The superclass is being looked up by its string name
		 * first among classes listed in package imports. If not found,
		 * the class is being searched globally.
		 *
		 * @param extendedClass subclass object
		 * @param baseClassName string name of the superclass
		 * @param packageImports array of class names imported in that package
		 * @return undefined
		 */
		applyInheritance : function(extendedClass, baseClassName, packageImports)
		{
			if(baseClassName === null)
			{
				return;
			}

			var baseClass = InternalClassUtils.getClassByName(baseClassName, packageImports);

			if(baseClass && baseClass._classInfo.extendable === 'final')
			{
				err('cannot extend final class ' + baseClass + '. Only dynamic classes can be extended.');
				return;
			}

			if(InternalClassUtils.isArray(baseClass))
			{
				err('base class name ' + baseClassName + ' in definition of ' + extendedClass + ' is ambiguous. Possible matches are ' + baseClass + '. Please provide full package name.');
				return;
			} else if(baseClass === null)
			{
				err('base class ' + baseClassName + ' in definition of ' + extendedClass + ' could not be found. Please make sure you import it with the Import() statement.');
				return;
			}

			var keys = Object.getOwnPropertyNames(baseClass.prototype);
			var name;

			for(var i = 0; i < keys.length; ++i)
			{
				name = keys[i];

				if(CLASS_MODEL.extensionDisabled.indexOf(name) === -1)
				{
					var baseScope = name in baseClass._classInfo.scope ? baseClass._classInfo.scope[name] : '_public';

					// check if it's an override
					if(extendedClass.prototype[name] === undefined)
					{
						if(CLASS_MODEL.inheritScope.indexOf(baseScope) !== -1 && InternalClassUtils[CLASS_MODEL.inheritConditions[baseScope]](extendedClass, baseClass))
						{
							// not an override
							if(typeof(baseClass.prototype[name]) === 'function')
							{
								extendedClass.prototype[name] = Scope.scopeInstance.method.transcribe(name, baseClass.prototype[name], extendedClass.prototype);
							} else
							{
								extendedClass.prototype[name] = baseClass.prototype[name];
							}
						}
					} else
					{
						// override, ensure compatibility
						if(typeof(baseClass.prototype[name]) === 'function')
						{
							if(typeof(extendedClass.prototype[name]) === 'function')
							{
								var extendedScope = name in extendedClass._classInfo.scope ? extendedClass._classInfo.scope[name] : '_public';
								if(CLASS_MODEL.inheritScope.indexOf(baseScope) !== -1 && InternalClassUtils[CLASS_MODEL.inheritConditions[baseScope]](extendedClass, baseClass))
								{
									if(baseScope === extendedScope)// || extendedScope === '_public')
									{
										if(InternalClassUtils.getNumFunctionArguments(baseClass.prototype[name]) === InternalClassUtils.getNumFunctionArguments(extendedClass.prototype[name]))
										{
											// all ok, override
											extendedClass.prototype[name] = Scope.scopeInstance.method.override(name, baseClass.prototype[name], extendedClass.prototype[name]);
										} else
										{
											err('incompatible override of function \'' + name + '\' originally defined in ' + baseClass + ' by class ' + extendedClass + '. Functions have different arguments count.');
										}
									} else
									{
										err('incompatible override of function \'' + name + '\' originally defined in ' + baseClass + ' by class ' + extendedClass + '. Cannot change function scope from ' + baseScope + ' to ' + extendedScope + '.');
									}
								} else
								{
									err('incompatible override of function \'' + name + '\' originally defined in ' + baseClass + ' by class ' + extendedClass + '. Functions of scope \'' + baseScope + '\' are not overridable.');
								}
							} else
							{
								err('illegal attempt to override a function \'' + name + '\' originally defined in ' + baseClass + ' by a variable of the same name in class ' + extendedClass + '. Functions can only be overridden by other functions.');
							}
						} else
						{
							err('illegal attempt to override a variable \'' + name + '\' originally defined in ' + baseClass + ' by class ' + extendedClass + '. Variables cannot be overridden. Please set their values in class constructor instead.');
						}
					}
				}
			}

			extendedClass.prototype.constructor = Scope.scopeInstance.constructor.override(extendedClass._classInfo.name, baseClass.prototype.constructor, extendedClass.prototype.constructor);
		},

		/**
		 * Function whose result determines whether inheritance sohuld be applied between specified classes of public scope.
		 *
		 * @param extendedClass subclass
		 * @param baseClass superclass
		 * @return boolean true if extension should be applied, false otherwise
		 */
		inheritConditionPublic : function(extendedClass, baseClass)
		{
			Poof.suppressUnused(extendedClass, baseClass);
			return true;
		},

		/**
		 * Function whose result determines whether inheritance sohuld be applied between specified classes of protected scope.
		 * TODO: revise expeced outcome and implement.
		 *
		 * @param extendedClass subclass
		 * @param baseClass superclass
		 * @return boolean true if extension should be applied, false otherwise
		 */
		inheritConditionProtected : function(extendedClass, baseClass)
		{
			Poof.suppressUnused(extendedClass, baseClass);
			return true;
		},

		/**
		 * Function whose result determines whether inheritance sohuld be applied between specified classes of internal scope.
		 * TODO: revise expeced outcome and implement.
		 *
		 * @param extendedClass subclass
		 * @param baseClass superclass
		 * @return boolean true if extension should be applied, false otherwise
		 */
		inheritConditionInternal : function(extendedClass, baseClass)
		{
			Poof.suppressUnused(extendedClass, baseClass);
			return true;
		},

		/**
		 * Registers an initialised Class object in global scope.
		 *
		 * @param packageName name of the Class's package
		 * @param className name of the Class to be registered
		 * @param classObject the Class object to be registered
		 * @return undefined
		 */
		registerClass : function(packageName, className, classObject)
		{
			if(!Poof.concatenated && InternalClassUtils.expectedClasses.indexOf(packageName + '.' + className) === -1)
			{
				err('package ' + packageName + ' or class name ' + className + ' do not match file\'s physical location');
				return;
			}

			InternalClassUtils.expectedClasses.splice(InternalClassUtils.expectedClasses.indexOf(packageName + '.' + className), 1);
			InternalClassUtils.classInstanceId[classObject] = 0;

			var completeHandler = function()
			{
				if(classObject._classInfo.qualifiedName in InternalClassUtils.classReadyListeners)
				{
					for(var i = 0; i < InternalClassUtils.classReadyListeners[classObject._classInfo.qualifiedName].length; ++i)
					{
						InternalClassUtils.classReadyListeners[classObject._classInfo.qualifiedName][i]();
					}
				}
			};

			if(InternalClassUtils.getClassByName(packageName + '.' + className) !== null)
			{
				// replace the current definition
				if(InternalClassUtils.isArray(window[className]))
				{
					for(var i = 0; i < window[className].length; ++i)
					{
						if(window[className][i]._classInfo.qualifiedName === packageName + '.' + className)
						{
							window[className][i] = classObject;
							break;
						}
					}
				} else
				{
					window[className] = classObject;
				}

				completeHandler();
				return;
			}

			if(InternalClassUtils.getClassByName(className) !== null)
			{
				if(!InternalClassUtils.isArray(window[className]))
				{
					if('_classInfo' in window[className] && window[className]._classInfo.qualifiedName !== classObject._classInfo.qualifiedName)
					{
						window[className] = [window[className]];
					}
				}
			}

			if(InternalClassUtils.isArray(window[className]))
			{
				window[className].push(classObject);
			} else
			{
				window[className] = classObject;
			}

			completeHandler();
		},

		/**
		 * Returns number of function arguments.
		 *
		 * @param f function whose arguments should be counted
		 * @return int numer of function arguments
		 */
		getNumFunctionArguments : function(f)
		{
			var fString = f.toString();
			var args = fString.substring(fString.indexOf('(') + 1, fString.indexOf(')'));
			var match = args.match(/,/);
			var argsCount = match ? match.length + 1 : (args === '' ? 0 : 1);
			return argsCount;
		},

		/**
		 * Handler called when Class finishes its initialisation.
		 *
		 * @param qualifiedClassName qualified name of Class for whose initialisation to wait
		 * @param handler function that should be called once Class's initialisation is complete
		 */
		onClassReady : function(qualifiedClassName, handler)
		{
			if(!(qualifiedClassName in InternalClassUtils.classReadyListeners))
			{
				InternalClassUtils.classReadyListeners[qualifiedClassName] = [];
			}

			InternalClassUtils.classReadyListeners[qualifiedClassName].push(handler);
		}
	};

	/**
	 * Core Package declaration function and initialiser.
	 *
	 * @param packageName name of the package
	 * @param contents package contents (Imports, Classes)
	 * @return undefined
	 */
	var Package = function(packageName, contents)
	{
		var loads = [];
		var imports = [];
		var classes = [];

		if(packageName === '')
		{
			packageName = 'default';
		}

		for(var i = 0; i < contents.length; ++i)
		{
			if(contents[i])
			{
				if('_loadInfo' in contents[i])
				{
					loads.push(contents[i]);
				} else if('_importInfo' in contents[i])
				{
					imports.push(contents[i]);
				} else if('_classInfo' in contents[i])
				{
					classes.push(contents[i]);
				} else
				{
					// unrecognised
					Poof.suppressUnused();
				}
			}
		}

		var importsCompleteHandler = function()
		{
			// resolve package object
			var packageNameComponents = packageName.split('.');
			var packageObject = Package;
			var currentPackageName = null;
			var i, length;
			if(!('_classes' in packageObject))
			{
				packageObject._classes = [];
				packageObject._classesByName = {};
			}

			for(i = 0, length = packageNameComponents.length; i < length; ++i)
			{
				if(!(packageNameComponents[i] in packageObject))
				{
					var parentObject = packageObject === Package ? null : packageObject;
					currentPackageName = currentPackageName === null ? packageNameComponents[i] : (currentPackageName + '.' + packageNameComponents[i]);
					packageObject[packageNameComponents[i]] =
					{
						_parent: parentObject,
						_name: currentPackageName,
						_classes: [],
						_classesByName: {}
					};
				}

				packageObject = packageObject[packageNameComponents[i]];
			}

			// register all classes from the pacakge
			for(i = 0, length = classes.length; i < length ; ++i)
			{
				classes[i]._classInfo.packageName = packageName;
				classes[i]._classInfo.qualifiedName = packageName + '.' + classes[i]._classInfo.name;
				packageObject._classes.push(classes[i]);
				packageObject._classesByName[classes[i]._classInfo.name] = classes[i];
				packageObject[classes[i]._classInfo.name] = classes[i];

				InternalClassUtils.applyInheritance(classes[i], classes[i]._classInfo.base, imports);
				InternalClassUtils.registerClass(classes[i]._classInfo.packageName, classes[i]._classInfo.name, classes[i]);
			}

			InternalClassUtils.onPackageCreationComplete();
		};

		var loadsCompleteHandler = function()
		{
			InternalClassUtils.loadBatch(imports, importsCompleteHandler);
		};

		var packageCreator = function()
		{
			InternalClassUtils.loadBatch(loads, loadsCompleteHandler);
		};

		InternalClassUtils.queuePackageCreation(packageCreator);
		InternalClassUtils.createNextPackage();
	};

	/**
	 * Core Class declaration function.
	 *
	 * @param declaration Class declaration
	 * @param definition Class definition object
	 * @return object Class object to be initialised by Package initialiser
	 */
	var Class = function(declaration, definition)
	{
		// parse class declaration
		var declarationInfo = InternalClassUtils.parseDeclaration(declaration);
		if(declarationInfo === undefined || declarationInfo === null)
		{
			window.console.warn('Error declaring class', declaration);
			return null;
		}
		declarationInfo.type = declarationInfo.type === null ? 'normal' : declarationInfo.type;

		// get standarized definition of the class
		var definitionInfo = InternalClassUtils.parseDefinition(definition);

		var customConstructor = (declarationInfo.name in definitionInfo[CLASS_MODEL.constructorScope]) ? definitionInfo[CLASS_MODEL.constructorScope][declarationInfo.name] : function() {};
		var constructor = function()
		{
			this._handlers = {};
			this.constructor.apply(this, arguments);
		};

		// create class object
		var classObject = InternalClassUtils.getScopedConstructor(declarationInfo.name, constructor, declarationInfo.type);

		// extend from PObject
		classObject.prototype = new PObject();

		// assign class to the instance
		classObject.prototype._class = classObject;

		// populate class ingo
		classObject._classInfo = {};
		classObject._classInfo.id = InternalClassUtils.classId ++;
		classObject._classInfo.name = declarationInfo.name;
		classObject._classInfo.base = declarationInfo.extend;
		classObject._classInfo.extendable = declarationInfo.extendable;
		classObject._classInfo.scope = {};

		InternalClassUtils.typeClass(classObject, declarationInfo.type);

		classObject.toString = function()
		{
			return '[Class ' + classObject.prototype._class._classInfo.packageName + '.' + classObject.prototype._class._classInfo.name + ']';
		};

		// transcribe class methods
		for(var i = 0; i < CLASS_MODEL.definitionFields.scopeClass.length; ++i)
		{
			InternalClassUtils.transcribeScope(definitionInfo[CLASS_MODEL.definitionFields.scopeClass[i]], classObject, 'scopeClass', CLASS_MODEL.definitionFields.scopeClass[i]);
		}

		// transcribe instance methods
		for(i = 0; i < CLASS_MODEL.definitionFields.scopeInstance.length; ++i)
		{
			InternalClassUtils.transcribeScope(definitionInfo[CLASS_MODEL.definitionFields.scopeInstance[i]], classObject.prototype, 'scopeInstance', CLASS_MODEL.definitionFields.scopeInstance[i], [declarationInfo.name]);
		}

		// assign constructor
		classObject.prototype.constructor = customConstructor;

		return classObject;
	};

	/**
	 * Provides asynchronous .js file loading.
	 *
	 * @param url path of a file to be loaded
	 * @param handler function to be called when loading is finished
	 * @return object Load object to be executed with .execute()
	 */
	var Load = function(url, handler)
	{
		if(typeof(Poof.loadCondition) === 'function')
		{
			if(!Poof.loadCondition())
			{
				return;
			}
		}

		var loadObject =
		{
			_loadInfo:
			{
				url: url
			},

			execute : function(handler)
			{
				var head = document.getElementsByTagName('head')[0];
				var script = document.createElement('script');
				script.type = 'text/javascript';
				script.src = url;

				var wrappedHandler = function(event) {
					if(this.readyState && this.readyState !== 'loaded' && this.readyState !== 'complete') {
						return;
					}

					script.onload = script.onreadystatechange = null;
					window.setTimeout(function() { handler(event); }, 1);
				};

				script.onload = script.onreadystatechange = wrappedHandler;
				head.insertBefore(script, head.firstChild);
			}
		};

		if(handler === undefined && handler !== null)
		{
			return loadObject;
		} else
		{
			loadObject.execute(handler);
		}
	};

	/**
	 * Provides asynchronous Class loading.
	 *
	 * @param className name of Class to be loaded
	 * @param handler function to be called when loading is finished
	 * @return object Import object to be executed with .execute()
	 */
	var Import = function(className, handler)
	{
		if(className.indexOf('.') === -1)
		{
			className = 'default.' + className;
		}

		var importObject =
		{
			_importInfo:
			{
				className		: InternalClassUtils.getClassNameFromQualifiedName(className),
				packageName		: className.indexOf('.') === -1 ? '' : className.substring(0, className.lastIndexOf('.'))
			},

			importPath		: InternalClassUtils.getClassFileUrlFromQualifiedName(className),

			execute			: function(handler)
			{
				var _this = this;

				var delayedExecute = function()
				{
					if(InternalClassUtils.getClassByName(className) || InternalClassUtils.expectedClasses.indexOf(className) !== -1)
					{
						handler(_this._importInfo);
						return;
					}

					console.log('-- [import] ', className);
					InternalClassUtils.packageCreationInProgress = false;

					InternalClassUtils.synchronousPackageInitialisation = false;

					if(typeof(handler) === 'function')
					{
						_this.handler = handler;
					}

					if(InternalClassUtils.loadedClasses.indexOf(_this.importPath) === -1)
					{
						if(InternalClassUtils.getClassByName(className) === null)
						{
							var head = document.getElementsByTagName('head')[0];
							var script = document.createElement('script');
							script.type = 'text/javascript';
							script.src = InternalClassUtils.getClassFileUrlFromQualifiedName(className);
							script.packageName = _this._importInfo.packageName;
							script.className = _this._importInfo.className;

							var self = _this;
							var wrappedHandler = function(event)
							{
								Poof.suppressUnused(event);

								if(this.readyState && this.readyState !== 'loaded' && this.readyState !== 'complete') {
									return;
								}

								script.onload = script.onreadystatechange = null;

								if(InternalClassUtils.getClassByName(self._importInfo.packageName + '.' + self._importInfo.className) !== null)
								{
									setTimeout(function()
									{
										self.handler(self._importInfo);
									}, 1);
								} else
								{
									InternalClassUtils.onClassReady(self._importInfo.packageName + '.' + self._importInfo.className, function()
									{
										setTimeout(function()
										{
											self.handler(self._importInfo);
										}, 1);
									});
								}
							};

							script.onload = script.onreadystatechange = wrappedHandler;

							InternalClassUtils.expectedClasses.push(className);

							head.insertBefore(script, head.firstChild);
						} else
						{
							if(_this.handler !== undefined)
							{
								_this.handler(_this._importInfo);
							}
						}
					} else
					{
						_this.handler(_this._importInfo);
					}
				};

				if(Poof.concatenated)
				{
					setTimeout(delayedExecute, InternalClassUtils.delayedImportTimeout);
				} else
				{
					delayedExecute();
				}
			}
		};

		if(handler === undefined && handler !== null)
		{
			return importObject;
		} else
		{
			importObject.execute(handler);
		}
	};

	/**
	 * Internal error logging function
	 *
	 * @param message message to be logged
	 * @param critical determines whether the error should be logged as native JS exception or just a console log
	 * @return undefined
	 */
	function err(message, critical)
	{
		if(Poof.debug)
		{
			if(critical)
			{
				throw new Error(getLogMessage('ERROR') + message);
			} else
			{
				window.console.warn(getLogMessage('ERROR'), message);
			}
		}
	}

	/**
	 * Generates message prefix to be logged
	 *
	 * @param type type of log message
	 * @return string message prefix to be logged
	 */
	function getLogMessage(type)
	{
		return '[POOF] [' + type + '] ';
	}

	/**
	 * Handler function called when main class referenced for Poof in .html finishes loading and initialising.
	 * Exposes the main class as window.main and constructs it.
	 *
	 * @param importInfo import info object passed to the handler from Import
	 * @return undefined
	 */
	function onMainClassRady(importInfo)
	{
		if(InternalClassUtils.getClassByName(importInfo.className) !== null)
		{
			var classObject = InternalClassUtils.getClassByName(importInfo.className);
			window.main = classObject._classInfo.type === 'singleton' ? classObject.getInstance() : new classObject();
		} else
		{
			err('could not instantiate main class ' + importInfo.packageName + '.' + importInfo.className);
			return;
		}
	}

	/**
	 * Poof initialiser function.
	 * Analises HTML's <script> tag, sets up Poof and triggers Import of the main class.
	 *
	 * @return undefined
	 */
	function init()
	{
		var scripts = document.getElementsByTagName('script');
		for(var i = 0; i < scripts.length; ++i)
		{
			if(scripts[i].hasAttribute('main'))
			{
				if(scripts[i].hasAttribute('root'))
				{
					Poof.importRoot = scripts[i].getAttribute('root');
				}

				if(scripts[i].hasAttribute('suffix'))
				{
					Poof.importSuffix = scripts[i].getAttribute('suffix');
				}

				if(scripts[i].hasAttribute('concatenated'))
				{
					Poof.concatenated = scripts[i].getAttribute('concatenated');
				}

				if(scripts[i].hasAttribute('debug'))
				{
					Poof.debug = scripts[i].getAttribute('debug') === 'true';
				}

				compatibilityFixes.applyAll();
				Import(scripts[i].getAttribute('main')).execute(onMainClassRady);
			}
		}
	}

	/**
	 * Exposes public interfaces.
	 */
	window.Poof = Poof;
	window.ClassUtils =
	{
		getClassNameFromQualifiedName : InternalClassUtils.getClassNameFromQualifiedName,
		getClassByName : InternalClassUtils.getClassByName,
		importBatch : InternalClassUtils.loadBatch
	};
	window.Package = Package;
	window.Class = Class;
	window.Import = Import;
	window.Load = Load;

	init();
})(window);
