codeunit 81185 "Calc Prod Order Sub"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Prod. Order", 'OnAfterTransferBOMComponent', '', false, false)]
    local procedure "Calculate Prod. Order_OnAfterTransferBOMComponent"(var ProdOrderLine: Record "Prod. Order Line"; var ProductionBOMLine: Record "Production BOM Line"; var ProdOrderComponent: Record "Prod. Order Component"; LineQtyPerUOM: Decimal; ItemQtyPerUOM: Decimal)
    begin
        ProdOrderComponent."Principal Input" := ProductionBOMLine."Principal Input";
    end;


    var
        myInt: Integer;
}