document.addEventListener("turbolinks:load", function () {

    $('.exercise').readmore({
        speed: 500,
        lessLink: '<a href="#">Show less</a>',
        moreLink: '<a href="#">Show more</a>',
        collapsedHeight: 30
    });
});