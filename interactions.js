function resetbutton(unclickedbutton) {
    $(unclickedbutton).removeClass('highlighted');
    $(unclickedbutton).removeClass('buttonhover');
}

function resetwindow(unclickedwindow,fadeinfn) {
    $(unclickedwindow).fadeOut(fadeinfn);
}

$(document).ready(function () {
    $('.navi').hide();
    /*$('.home').hide();
    $('.code').hide();
    $('.design').hide();
    $('.arts').hide();*/
    $('.main').hide();
    $('.codecontent').hide();
    $('.designcontent').hide();
    $('.artscontent').hide();

    $('.navi').fadeIn(2000);
    /*$('.home').fadeIn(1900);
    $('.code').fadeIn(2200);
    $('.design').fadeIn(2500);
    $('.arts').fadeIn(2800);*/
    $('.main').fadeIn(1500);
    $('.home').addClass('highlighted');
    $('.home').addClass('buttonhover');

    $('.home').click(function () {
        $(this).addClass('highlighted');
        $(this).addClass('buttonhover');
        resetbutton('.code');
        resetbutton('.design');
        resetbutton('.arts');

        if ($('.codecontent').is(':visible')) {
            resetwindow('.codecontent',
                function () {$('.homecontent').fadeIn(1400);});
        }
        else if ($('.designcontent').is(':visible')) {
            resetwindow('.designcontent',
                function () {$('.homecontent').fadeIn(1400);});
        }
        else if ($('.artscontent').is(':visible')) {
            resetwindow('.artscontent',
                function () {$('.homecontent').fadeIn(1400);});
        }
    });

    $('.code').click(function () {
        $(this).addClass('highlighted');
        $(this).addClass('buttonhover');
        resetbutton('.home');
        resetbutton('.design');
        resetbutton('.arts');

        if ($('.homecontent').is(':visible')) {
            resetwindow('.homecontent',
                function () {$('.codecontent').fadeIn(1400);});
        }
        else if ($('.designcontent').is(':visible')) {
            resetwindow('.designcontent',
                function () {$('.codecontent').fadeIn(1400);});
        }
        else if ($('.artscontent').is(':visible')) {
            resetwindow('.artscontent',
                function () {$('.codecontent').fadeIn(1400);});
        }
    });

    $('.design').click(function () {
        $(this).addClass('highlighted');
        $(this).addClass('buttonhover');
        resetbutton('.home');
        resetbutton('.code');
        resetbutton('.arts');

        if ($('.homecontent').is(':visible')) {
            resetwindow('.homecontent',
                function () {$('.designcontent').fadeIn(1400);});
        }
        else if ($('.codecontent').is(':visible')) {
            resetwindow('.codecontent',
                function () {$('.designcontent').fadeIn(1400);});
        }
        else if ($('.artscontent').is(':visible')) {
            resetwindow('.artscontent',
                function () {$('.designcontent').fadeIn(1400);});
        }
    });

    $('.arts').click(function () {
        $(this).addClass('highlighted');
        $(this).addClass('buttonhover');
        resetbutton('.home');
        resetbutton('.code');
        resetbutton('.design');

        if ($('.homecontent').is(':visible')) {
            resetwindow('.homecontent',
                function () {$('.artscontent').fadeIn(1400);});
        }
        else if ($('.codecontent').is(':visible')) {
            resetwindow('.codecontent',
                function () {$('.artscontent').fadeIn(1400);});
        }
        else if ($('.designcontent').is(':visible')) {
            resetwindow('.designcontent',
                function () {$('.artscontent').fadeIn(1400);});
        }
    });

});