package com.umiwi.control.component
{
    import fl.controls.listClasses.CellRenderer; 
    
    public class MultiLineCell extends CellRenderer 
    { 
        
        public function MultiLineCell() 
        {     
            textField.wordWrap = true; 
            textField.autoSize = "left"; 
        } 
        override protected function drawLayout():void {             
            textField.width = this.width; 
            super.drawLayout(); 
        } 
    } 
}