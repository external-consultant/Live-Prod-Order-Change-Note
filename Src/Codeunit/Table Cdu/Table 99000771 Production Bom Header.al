codeunit 81186 Production_Bom_Header_Sub
{

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Header", 'OnBeforeValidateEvent', 'Status', false, false)]
    local procedure OnBeforeValidateEvent(var Rec: Record "Production BOM Header")
    var
        ProductionBOMLines_lRec: Record "Production BOM Line";
        PrincipalInputTotal: Decimal;
    begin
        ProductionBOMLines_lRec.Reset();
        ProductionBOMLines_lRec.SetRange("Production BOM No.", Rec."No.");
        ProductionBOMLines_lRec.SetRange("Principal Input", true);
        ProductionBOMLines_lRec.SetRange("Version Code", '');
        if ProductionBOMLines_lRec.FindSet() then
            repeat
                PrincipalInputTotal := PrincipalInputTotal + ProductionBOMLines_lRec."Quantity per";
            until ProductionBOMLines_lRec.Next() = 0;

        if ((PrincipalInputTotal <> 1)) and (PrincipalInputTotal <> 0) then
            Error('The Total sum of Component Quantity of Principle Input lines should be "1". Currently total value =%1', PrincipalInputTotal);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM", 'OnBeforeSendforApprovalBOM', '', false, false)]
    local procedure "Production BOM_OnBeforeSendforApprovalBOM"(var ProductionBOMHeader: Record "Production BOM Header")
    var
        ProductionBOMLines_lRec: Record "Production BOM Line";
        PrincipalInputTotal: Decimal;
    begin
        ProductionBOMLines_lRec.Reset();
        ProductionBOMLines_lRec.SetRange("Production BOM No.", ProductionBOMHeader."No.");
        ProductionBOMLines_lRec.SetRange("Principal Input", true);
        ProductionBOMLines_lRec.SetRange("Version Code", '');
        if ProductionBOMLines_lRec.FindSet() then
            repeat
                PrincipalInputTotal := PrincipalInputTotal + ProductionBOMLines_lRec."Quantity per";
            until ProductionBOMLines_lRec.Next() = 0;

        if ((PrincipalInputTotal <> 1)) and (PrincipalInputTotal <> 0) then
            Error('The Total sum of Component Quantity of Principle Input lines should be "1". Currently total value =%1', PrincipalInputTotal);
    end;



    var
        myInt: Integer;
}