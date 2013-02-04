class AbstractChapter extends Abstract

    tagName             : 'div'
    className           : 'area'
    chapterInstructions : null

    addChapterInstructions : =>
    	
        @chapterInstructions = new InstructionsChapter()
        @addChild @chapterInstructions

        null