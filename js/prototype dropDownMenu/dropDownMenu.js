var dropDownMenu = Class.create();
dropDownMenu.prototype = {
    initialize:function(cls){
        this.cls = cls;
        this.init();
    },
    
    init:function(){
        $$(this.cls).each(function(o){
            o.observe("mouseover",function(){o.down(1).show()});
            o.observe("mouseout",function(){o.down(1).hide()});
        });
    }
};

document.observe("dom:loaded",function(){
    var newMenu = new dropDownMenu(".nav_li");
});