Codeunit 81181 Subscribe_Codeunit_5407
{
//T12149-NS
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", 'OnTransProdOrderOnBeforeToProdOrderInsert', '', false, false)]
    local procedure OnTransProdOrderOnBeforeToProdOrderInsert(var ToProdOrder: Record "Production Order"; FromProdOrder: Record "Production Order"; NewPostingDate: Date);
    var
        ProdOrderChangeNoteHeader_lRec: Record "Prod. Order Change Note Header";
        ModProdOrderChangeNoteHeader_lRec: Record "Prod. Order Change Note Header";
    begin

        ProdOrderChangeNoteHeader_lRec.RESET;
        ProdOrderChangeNoteHeader_lRec.SETRANGE("Prod. Order No.", FromProdOrder."No.");
        IF ProdOrderChangeNoteHeader_lRec.FINDSET THEN BEGIN
            REPEAT
                ModProdOrderChangeNoteHeader_lRec.GET(ProdOrderChangeNoteHeader_lRec."No.");
                ModProdOrderChangeNoteHeader_lRec."Prod. Order Status" := ToProdOrder.Status;
                ModProdOrderChangeNoteHeader_lRec."Prod. Order No." := ToProdOrder."No.";
                ModProdOrderChangeNoteHeader_lRec.MODIFY;
            UNTIL ProdOrderChangeNoteHeader_lRec.NEXT = 0;
        END;
    end;
    //T12149-NE
}

