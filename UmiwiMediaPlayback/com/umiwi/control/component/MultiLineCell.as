package com.umiwi.control.component
{
    import fl.controls.listClasses.CellRenderer;
    
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    
    public class MultiLineCell extends CellRenderer 
    { 
      
        private var format:TextFormat;
        public function MultiLineCell() 
        {     
            format = new TextFormat();
            format.font = "Arial";
            format.color = 0xCCCCCC;
            format.size = 12;
            //format.align = TextFormatAlign.CENTER;
            
            textField.wordWrap = true; 
            textField.autoSize = "left"; 
        } 
        override protected function drawLayout():void {
            textField.width = this.width; 
            textField.height = this.height;
            textField.setTextFormat(format);
            super.drawLayout(); 
        } 
    } 
}