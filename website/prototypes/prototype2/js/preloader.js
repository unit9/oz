preloader = (function()
{
    var domElement, playButton, content, span, totalAssets;

    domElement = document.createElement('div');
    domElement.setAttribute('id', 'preloader');

    content = document.createElement('div');
    domElement.appendChild(content);

    span = document.createElement('span');
    content.appendChild(span);

    playButton = document.createElement('button');
    playButton.innerHTML = 'Play';
    
    return {
        show: function()
        {
            document.body.appendChild(domElement);

            totalAssets = numBuffersLoading + numTexturesLoading;
        },

        update: function()
        {
            var leftToLoad = numBuffersLoading + numTexturesLoading,
                assetsLoaded = totalAssets - leftToLoad;

            span.innerHTML = assetsLoaded.toString().concat(' of ', totalAssets, ' assets loaded');
        },

        showPrompt: function(callback)
        {
            playButton.onclick = callback;
            content.appendChild(playButton);
        },

        hide: function()
        {
            document.body.removeChild(domElement);
        }
    };
})();
