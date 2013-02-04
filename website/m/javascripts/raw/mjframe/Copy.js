/*global Package */
/*global Import */
/*global Class */

/*global Copy */

Package('mjframe',
[
	Class('public abstract Copy',
	{
		_public_static:
		{
			EVENT_LOCALE_CHANGE : 'Copy.EventLocaleChange',

			REGEXP_TAG_COPY : /\{\{\#[a-zA-Z0-9\.\_]*\}\}/g,

			useSharedCopy : false,
			sharedCopyClass : null,

			load : function(locale, platform, name, handler)
			{
				Import('copy.' + locale + '.' + platform + '.Copy' + name, handler);
			}
		},

		_public:
		{
			get : function(id)
			{
				return this[id];
			},

			compile : function(input)
			{
				var toReplace = input.match(Copy.REGEXP_TAG_COPY);

				if(!toReplace) {
					return input;
				}

				var i, length;
				for(i = 0, length = toReplace.length; i < length; i ++)
				{
					var tag = toReplace[i];
					var replacement = this.resolveCopyFromTag(tag);
					if(replacement === null)
					{
						input = input.replace(tag, '[COPY NOT FOUND]');
					} else
					{
						input = input.replace(tag, replacement);
					}
				}

				return input;
			},

			resolveCopyFromTag : function(tag)
			{
				if(typeof(tag) !== 'string')
				{
					return null;
				}

				tag = tag.substring(3, tag.length - 2);
				var tagComponents = tag.split('.');
				var value = this;
				var i, length;
				for(i = 0, length = tagComponents.length; i < length; i ++)
				{
					if(tagComponents[i] in value)
					{
						value = value[tagComponents[i]];
					} else
					{
						return null;
					}
				}

				return value;
			}
		}
	})
]);
