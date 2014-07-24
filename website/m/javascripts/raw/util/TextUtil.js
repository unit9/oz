/*global Package */
/*global Class */

/*global TextUtil */

Package('util',
[
	Class('public singleton TextUtil',
	{
		_public_static:
		{
			CHECK_STEP : 1,
			WHITE_SPACE_REGEXP : new RegExp('[ \t\r\n]')
		},

		_public:
		{
			TextUtil : function()
			{
				String.prototype.regexIndexOf = function(regex, startpos)
				{
					var indexOf = this.substring(startpos || 0).search(regex);
					return (indexOf >= 0) ? (indexOf + (startpos || 0)) : indexOf;
				};

				String.prototype.regexLastIndexOf = function(regex, startpos)
				{
					regex = (regex.global) ? regex : new RegExp(regex.source, "g" + (regex.ignoreCase ? "i" : "") + (regex.multiLine ? "m" : ""));
					if(typeof(startpos) === 'undefined')
					{
						startpos = this.length;
					} else if(startpos < 0)
					{
						startpos = 0;
					}
					var stringToWorkWith = this.substring(0, startpos + 1);
					var lastIndexOf = -1;
					var nextStop = 0;
					var result;
					while((result = regex.exec(stringToWorkWith)) !== null)
					{
						lastIndexOf = result.index;
						regex.lastIndex = ++nextStop;
					}
					return lastIndexOf;
				};
			},

			getNumLines : function($textContainer)
			{
				return $textContainer.height() / parseInt($textContainer.css('line-height'), 10);
			},

			getLine : function($textContainer, lineIndex)
			{
				var numLines = this.getNumLines($textContainer);
				return lineIndex < numLines ? this.getTextLines($textContainer)[lineIndex] : null;
			},

			getTextLines : function($textContainer)
			{
				var lines = [];
				var numLinesTotal = $textContainer.height() / parseInt($textContainer.css('line-height'), 10);
				var text = $.trim($textContainer.text());
				var averageNumCharactersPerLine = text.length / numLinesTotal;
				var lastLineIndex = 0;

				for(var i = 0; i < numLinesTotal; i ++)
				{
					var currentEndIndex = lastLineIndex + averageNumCharactersPerLine;
					var currentLine = text.substring(lastLineIndex, currentEndIndex);
					if(currentLine.length === 0)
					{
						break;
					}

					$textContainer.text(currentLine);
					var numLines = $textContainer.height() / parseInt($textContainer.css('line-height'), 10);
					var step = TextUtil.CHECK_STEP;
					var destNumLines = 2;
					var addToResult = -TextUtil.CHECK_STEP;

					if(numLines > 1)
					{
						step = -step;
						destNumLines = 1;
						addToResult = 0;
					}

					while(numLines !== destNumLines && currentEndIndex < text.length)
					{
						currentEndIndex += step;
						currentLine = text.substring(lastLineIndex, currentEndIndex);
						$textContainer.text(currentLine);
						numLines = $textContainer.height() / parseInt($textContainer.css('line-height'), 10);
					}

					currentEndIndex += addToResult;

					if(text.regexIndexOf(TextUtil.WHITE_SPACE_REGEXP, currentEndIndex) !== currentEndIndex && currentEndIndex < text.length)
					{
						currentEndIndex = text.substring(0, currentEndIndex).regexLastIndexOf(TextUtil.WHITE_SPACE_REGEXP);
					}
					currentLine = text.substring(lastLineIndex, currentEndIndex);
					lastLineIndex = currentEndIndex;

					lines.push(currentLine);
				}

				$textContainer.text(text);

				return lines;
			},

			breakIntoLines : function($textContainer)
			{
				var lines = this.getTextLines($textContainer);
				var $parent = $textContainer.parent();
				var $lineContainer = $textContainer.clone();
				$textContainer.remove();
				for(var i = 0; i < lines.length; i ++)
				{
					var $line = $lineContainer.clone();
					$line.text(lines[i]);
					$parent.append($line);
				}
			}
		}
	})
]);