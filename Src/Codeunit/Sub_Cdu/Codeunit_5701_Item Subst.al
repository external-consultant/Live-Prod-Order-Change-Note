Codeunit 81182 Subscribe_Codeunit_5701
{

    trigger OnRun()
    begin
    end;

    var
        TempItemSubstitution: Record "Item Substitution" temporary;
        SaveQty: Decimal;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Item: Record Item;
        ItemSubstitution: Record "Item Substitution";
        Text001: label 'An Item Substitution with the specified variant does not exist for Item No. ''%1''.';
        Text002: label 'An Item Substitution does not exist for Item No. ''%1''';
        AvailToPromise: Codeunit "Available to Promise";
        GrossReq: Decimal;
        SchedRcpt: Decimal;

    //T12149-NS
    procedure GetCompSubstChangeNote_gFnc(var ProdOrderChangeNoteLine_vRec: Record "Prod. Order Change Note Line"): Code[10]
    begin
        //ProdOrderChangeNote-NS
        if not PrepareSubstList(
             ProdOrderChangeNoteLine_vRec."Item No.",
             ProdOrderChangeNoteLine_vRec."Variant Code",
             ProdOrderChangeNoteLine_vRec."Location Code",
             ProdOrderChangeNoteLine_vRec."Due Date",
             true)
        then
            ErrorMessage(ProdOrderChangeNoteLine_vRec."Item No.", ProdOrderChangeNoteLine_vRec."Variant Code");

        TempItemSubstitution.Reset;
        TempItemSubstitution.SetRange("Variant Code", ProdOrderChangeNoteLine_vRec."Variant Code");
        TempItemSubstitution.SetRange("Location Filter", ProdOrderChangeNoteLine_vRec."Location Code");
        if TempItemSubstitution.Find('-') then;
        if Page.RunModal(Page::"Item Substitution Entries", TempItemSubstitution) = Action::LookupOK then
            UpdateComponentChangeNote_gFnc(ProdOrderChangeNoteLine_vRec, TempItemSubstitution."Substitute No.", TempItemSubstitution."Substitute Variant Code");
        //ProdOrderChangeNote-NE
    end;


    procedure UpdateComponentChangeNote_gFnc(var ProdOrderChangeNoteLine_vRec: Record "Prod. Order Change Note Line"; SubstItemNo: Code[20]; SubstVariantCode: Code[10])
    var
        TempProdOrderChangeNoteLine: Record "Prod. Order Change Note Line" temporary;
    begin
        //ProdOrderChangeNote-NS
        TempProdOrderChangeNoteLine := ProdOrderChangeNoteLine_vRec;

        SaveQty := TempProdOrderChangeNoteLine."Quantity Per";

        TempProdOrderChangeNoteLine."Item No." := SubstItemNo;
        TempProdOrderChangeNoteLine."Variant Code" := SubstVariantCode;
        TempProdOrderChangeNoteLine."Location Code" := ProdOrderChangeNoteLine_vRec."Location Code";
        TempProdOrderChangeNoteLine."Quantity Per" := 0;
        TempProdOrderChangeNoteLine.Validate("Item No.");
        TempProdOrderChangeNoteLine.Validate("Variant Code");

        TempProdOrderChangeNoteLine."Original Item No." := ProdOrderChangeNoteLine_vRec."Item No.";
        TempProdOrderChangeNoteLine."Original Variant Code" := ProdOrderChangeNoteLine_vRec."Variant Code";

        if ProdOrderChangeNoteLine_vRec."Qty. per Unit of Measure" <> 1 then begin
            if ItemUnitOfMeasure.Get(Item."No.", ProdOrderChangeNoteLine_vRec."Unit of Measure Code") and
               (ItemUnitOfMeasure."Qty. per Unit of Measure" = ProdOrderChangeNoteLine_vRec."Qty. per Unit of Measure")
            then
                TempProdOrderChangeNoteLine.Validate("Unit of Measure Code", ProdOrderChangeNoteLine_vRec."Unit of Measure Code")
            else
                SaveQty := ROUND(ProdOrderChangeNoteLine_vRec."Quantity Per" * ProdOrderChangeNoteLine_vRec."Qty. per Unit of Measure", 0.00001);
        end;
        TempProdOrderChangeNoteLine.Validate("New Quantity Per", SaveQty);
        TempProdOrderChangeNoteLine."Substitute Selected" := true;

        ProdOrderChangeNoteLine_vRec := TempProdOrderChangeNoteLine;
        //ProdOrderChangeNote-NE
    end;


    procedure PrepareSubstList(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; DemandDate: Date; CalcATP: Boolean): Boolean
    begin
        Item.Get(ItemNo);
        Item.SetFilter("Location Filter", LocationCode);
        Item.SetFilter("Variant Filter", VariantCode);
        Item.SetRange("Date Filter", 0D, DemandDate);

        ItemSubstitution.Reset;
        ItemSubstitution.SetRange(Type, ItemSubstitution.Type::Item);
        ItemSubstitution.SetRange("No.", ItemNo);
        ItemSubstitution.SetRange("Variant Code", VariantCode);
        ItemSubstitution.SetRange("Location Filter", LocationCode);
        if ItemSubstitution.Find('-') then begin
            TempItemSubstitution.DeleteAll;
            CreateSubstList(ItemNo, ItemSubstitution, 1, DemandDate, CalcATP);
            exit(true);
        end;

        exit(false);
    end;


    procedure ErrorMessage(ItemNo: Code[20]; VariantCode: Code[10])
    begin
        if VariantCode <> '' then
            Error(Text001, ItemNo);

        Error(Text002, ItemNo);
    end;

    local procedure CreateSubstList(OrgNo: Code[20]; var ItemSubstitution3: Record "Item Substitution"; RelationsLevel: Integer; DemandDate: Date; CalcATP: Boolean)
    var
        ItemSubstitution: Record "Item Substitution";
        ItemSubstitution2: Record "Item Substitution";
        RelationsLevel2: Integer;
        ODF: DateFormula;
    begin
        ItemSubstitution.Copy(ItemSubstitution3);
        RelationsLevel2 := RelationsLevel;

        if ItemSubstitution.Find('-') then
            repeat
                Clear(TempItemSubstitution);
                TempItemSubstitution.Type := ItemSubstitution.Type;
                TempItemSubstitution."No." := ItemSubstitution."No.";
                TempItemSubstitution."Variant Code" := ItemSubstitution."Variant Code";
                TempItemSubstitution."Substitute Type" := ItemSubstitution."Substitute Type";
                TempItemSubstitution."Substitute No." := ItemSubstitution."Substitute No.";
                TempItemSubstitution."Substitute Variant Code" := ItemSubstitution."Substitute Variant Code";
                TempItemSubstitution.Description := ItemSubstitution.Description;
                TempItemSubstitution.Interchangeable := ItemSubstitution.Interchangeable;
                TempItemSubstitution."Location Filter" := ItemSubstitution."Location Filter";
                TempItemSubstitution."Relations Level" := RelationsLevel2;
                TempItemSubstitution."Shipment Date" := DemandDate;

                if CalcATP then begin
                    Item.Get(ItemSubstitution."Substitute No.");
                    TempItemSubstitution."Quantity Avail. on Shpt. Date" :=
                      AvailToPromise.CalcQtyAvailableToPromise(
                        Item, GrossReq, SchedRcpt,
#pragma warning disable
                        Item.GetRangemax("Date Filter"), 2, ODF);
#pragma warning disable
                    Item.CalcFields(Inventory);
                    TempItemSubstitution.Inventory := Item.Inventory;
                end;

                if IsSubstitutionInserted(TempItemSubstitution, ItemSubstitution) then begin
                    ItemSubstitution2.SetRange(Type, ItemSubstitution.Type);
                    ItemSubstitution2.SetRange("No.", ItemSubstitution."Substitute No.");
                    ItemSubstitution2.SetFilter("Substitute No.", '<>%1&<>%2', ItemSubstitution."No.", OrgNo);
                    ItemSubstitution.Copyfilter("Variant Code", ItemSubstitution2."Variant Code");
                    ItemSubstitution.Copyfilter("Location Filter", ItemSubstitution2."Location Filter");
                    if ItemSubstitution2.FindFirst then
                        CreateSubstList(OrgNo, ItemSubstitution2, RelationsLevel2 + 1, DemandDate, CalcATP);
                end else begin
                    TempItemSubstitution.Reset;
                    if TempItemSubstitution.Find then
                        if RelationsLevel2 < TempItemSubstitution."Relations Level" then begin
                            TempItemSubstitution."Relations Level" := RelationsLevel2;
                            TempItemSubstitution.Modify;
                        end;
                end;
            until ItemSubstitution.Next = 0;
    end;

    local procedure IsSubstitutionInserted(var ItemSubstitutionToCheck: Record "Item Substitution"; ItemSubstitution: Record "Item Substitution"): Boolean
    begin
        if ItemSubstitution."Substitute No." <> '' then begin
            ItemSubstitutionToCheck.Reset;
            ItemSubstitutionToCheck.SetRange("Substitute Type", ItemSubstitution."Substitute Type");
            ItemSubstitutionToCheck.SetRange("Substitute No.", ItemSubstitution."Substitute No.");
            ItemSubstitutionToCheck.SetRange("Substitute Variant Code", ItemSubstitution."Substitute Variant Code");
            if ItemSubstitutionToCheck.IsEmpty then
                exit(ItemSubstitutionToCheck.Insert);
        end;
        exit(false);
    end;
    //T12149-NE
}

