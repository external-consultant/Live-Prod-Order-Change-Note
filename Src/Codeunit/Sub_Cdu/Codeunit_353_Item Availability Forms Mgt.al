Codeunit 81180 Subscribe_Codeunit_353
{

    trigger OnRun()
    begin
    end;

    var
        ItemAvailabilityFormsMgt_gCdu: Codeunit "Item Availability Forms Mgt";
        ItemAvailByBOMLevel: Page "Item Availability by BOM Level";
        ForecastName: Code[10];
        AvailabilityType: Option Date,Variant,Location,Bin,"Event",BOM;
        Text012: label 'Do you want to change %1 from %2 to %3?', Comment = '%1=FieldCaption, %2=OldDate, %3=NewDate';

    //T12149-NS
    procedure ShowItemAvailFromChangeNoteSubform_gFnc(var ProdOrderChangeNoteLine_vRec: Record "Prod. Order Change Note Line"; AvailabilityType: Option Date,Variant,Location,Bin,"Event",BOM)
    var
        Item: Record Item;
        NewDate: Date;
        NewVariantCode: Code[10];
        NewLocationCode: Code[10];
        LocationCode: Code[20];
        VariantCode: Code[20];
        Date: Date;
    begin
        //ProdOrderChangeNote-NS
        ProdOrderChangeNoteLine_vRec.TestField("Item No.");
        Item.Reset;
        Item.Get(ProdOrderChangeNoteLine_vRec."Item No.");
        FilterItem(Item, ProdOrderChangeNoteLine_vRec."Location Code", ProdOrderChangeNoteLine_vRec."Variant Code", ProdOrderChangeNoteLine_vRec."Due Date");

        case AvailabilityType of
            Availabilitytype::Date:
                if ItemAvailabilityFormsMgt_gCdu.ShowItemAvailByDate(Item, ProdOrderChangeNoteLine_vRec.FieldCaption("Due Date"), ProdOrderChangeNoteLine_vRec."Due Date", NewDate) then
                    ProdOrderChangeNoteLine_vRec.Validate("Due Date", NewDate);
            Availabilitytype::Variant:
                if ItemAvailabilityFormsMgt_gCdu.ShowItemAvailVariant(Item, ProdOrderChangeNoteLine_vRec.FieldCaption("Variant Code"), ProdOrderChangeNoteLine_vRec."Variant Code", NewVariantCode) then
                    ProdOrderChangeNoteLine_vRec.Validate("Variant Code", NewVariantCode);
            Availabilitytype::Location:
                if ItemAvailabilityFormsMgt_gCdu.ShowItemAvailByLoc(Item, ProdOrderChangeNoteLine_vRec.FieldCaption("Location Code"), ProdOrderChangeNoteLine_vRec."Location Code", NewLocationCode) then
                    ProdOrderChangeNoteLine_vRec.Validate("Location Code", NewLocationCode);
            Availabilitytype::"Event":
                if ItemAvailabilityFormsMgt_gCdu.ShowItemAvailByEvent(Item, ProdOrderChangeNoteLine_vRec.FieldCaption("Due Date"), ProdOrderChangeNoteLine_vRec."Due Date", NewDate, false) then
                    ProdOrderChangeNoteLine_vRec.Validate("Due Date", NewDate);
            Availabilitytype::BOM:
                if ItemAvailabilityFormsMgt_gCdu.ShowItemAvailByBOMLevel(Item, ProdOrderChangeNoteLine_vRec.FieldCaption("Due Date"), ProdOrderChangeNoteLine_vRec."Due Date", NewDate) then
                    ProdOrderChangeNoteLine_vRec.Validate("Due Date", NewDate);
        end;
        //ProdOrderChangeNote-NE
    end;

    local procedure FilterItem(var Item: Record Item; LocationCode: Code[20]; VariantCode: Code[20]; Date: Date)
    begin
        // Do not make global
        // Request to make function global has been rejected as it is a skeleton function of the codeunit
        Item.SetRange("No.", Item."No.");
        Item.SetRange("Date Filter", 0D, Date);
        Item.SetRange("Variant Filter", VariantCode);
        Item.SetRange("Location Filter", LocationCode);
    end;
    //T12149-NE
}

