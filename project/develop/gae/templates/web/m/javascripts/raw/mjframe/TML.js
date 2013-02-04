/*global Package */
/*global Import */
/*global Class */
/*global ClassUtils */

/*global TML */

Package('mjframe',
[
	/**
	 * Template Markup Language
	 */
	Class('public TML',
	{
		_public_static:
		{
			REGEXP_TAG_VARIABLE : /\{\{\@[a-zA-Z0-9\.\_]*\}\}/g,
			REGEXP_LOGIC_IF_TRUE : /\{\{IF true\}\}/g,

			compile : function(models, input)
			{
				var result = input;
				for(var i in models)
				{
					var model = models[i];
					if(model !== null)
					{
						result = TML.compileModel(model, result);
					}
				}

				result = TML.compileModel(null, result, true);
				result = TML.compileLogic(result);

				return result;
			},

			compileModel : function(model, input, setUndefined)
			{
				var toReplace = input.match(TML.REGEXP_TAG_VARIABLE);
				if(!toReplace) {
					return input;
				}

				var i, length;
				for( i = 0, length = toReplace.length; i < length; i ++)
				{
					var tag = toReplace[i];
					var replacement = TML.resolveVariable(model, tag);
					if(replacement !== null && typeof(replacement) !== 'undefined')
					{
						input = input.replace(tag, replacement);
					} else if(setUndefined)
					{
						input = input.replace(tag, '{{UNDEFINED}}');
					}
				}

				return input;
			},

			compileLogic : function(input)
			{
				// true
				var index = input.indexOf('{{IF true}}');
				var index2;
				var begTag;
				var endIndexElse;
				var endIndexEndIf;
				while(index !== -1)
				{
					endIndexElse = input.indexOf('{{ELSE}}', index);
					endIndexEndIf = input.indexOf('{{/IF}}', index);
					if(endIndexElse !== -1)
					{
						input = input.substring(0, endIndexElse) + input.substring(endIndexEndIf + '{{/IF}}'.length, input.length);
					} else
					{
						input = input.substring(0, endIndexEndIf) + input.substring(endIndexEndIf + '{{/IF}}'.length, input.length);
					}
					input = input.substring(0, index) + input.substring(index + '{{IF true}}'.length, input.length);

					index = input.indexOf('{{IF true}}');
				}

				// false or undefined
				begTag = '{{IF false}}';
				index = input.indexOf(begTag);
				index2 = input.indexOf('{{IF {{UNDEFINED}}}}');

				if(index2 !== -1 && (index === -1 || index2 < index))
				{
					index = index2;
					begTag = '{{IF {{UNDEFINED}}}}';
				}
				while(index !== -1)
				{
					endIndexElse = input.indexOf('{{ELSE}}', index);
					endIndexEndIf = input.indexOf('{{/IF}}', index);
					if(endIndexElse !== -1)
					{
						input = input.substring(0, endIndexEndIf) + input.substring(endIndexEndIf + '{{/IF}}'.length, input.length);
						input = input.substring(0, index) + input.substring(endIndexElse + '{{ELSE}}'.length, input.length);
					} else
					{
						input = input.substring(0, index) + input.substring(endIndexEndIf + '{{/IF}}'.length, input.length);
					}

					begTag = '{{IF false}}';
					index = input.indexOf(begTag);
					index2 = input.indexOf('{{IF {{UNDEFINED}}}}');

					if(index2 !== -1 && (index === -1 || index2 < index))
					{
						index = index2;
						begTag = '{{IF {{UNDEFINED}}}}';
					}
				}
				return input;
			},

			resolveVariable : function(model, tag)
			{
				tag = tag.substring(3, tag.length - 2);
				var components = tag.split('.');
				var value = model;
				if(value === null || typeof(value) === 'undefined')
				{
					return null;
				}

				var i, length;
				for( i = 0, length = components.length; i < length;  i ++)
				{
					if(components[i] in value)
					{
						value = value[components[i]];
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
