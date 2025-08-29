codeunit 81187 Production_Bom_Version_Sub
{

    [EventSubscriber(ObjectType::Table, Database::"Production BOM Version", 'OnBeforeValidateEvent', 'Status', false, false)]
    local procedure OnBeforeValidateEvent(var Rec: Record "Production BOM Version")
    var
        ProductionBOMLines_lRec: Record "Production BOM Line";
        PrincipalInputTotal: Decimal;
    begin
        ProductionBOMLines_lRec.Reset();
        ProductionBOMLines_lRec.SetRange("Production BOM No.", Rec."Production BOM No.");
        ProductionBOMLines_lRec.SetRange("Principal Input", true);
        ProductionBOMLines_lRec.SetRange("Version Code", Rec."Version Code");
        if ProductionBOMLines_lRec.FindSet() then
            repeat
                PrincipalInputTotal := PrincipalInputTotal + ProductionBOMLines_lRec."Quantity per";
            until ProductionBOMLines_lRec.Next() = 0;

        if ((PrincipalInputTotal <> 1)) and (PrincipalInputTotal <> 0) then
            Error('The Total sum of Component Quantity of Principle Input lines should be "1". Currently total value =%1', PrincipalInputTotal);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Production BOM Version", OnBeforeActionEvent, "Send Approval Request", false, false)]
    local procedure "Production BOM_OnBeforeSendforApprovalBOM"(var Rec: Record "Production BOM Version")
    var
        ProductionBOMLines_lRec: Record "Production BOM Line";
        PrincipalInputTotal: Decimal;
    begin
        ProductionBOMLines_lRec.Reset();
        ProductionBOMLines_lRec.SetRange("Production BOM No.", Rec."Production BOM No.");
        ProductionBOMLines_lRec.SetRange("Principal Input", true);
        ProductionBOMLines_lRec.SetRange("Version Code", Rec."Version Code");
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