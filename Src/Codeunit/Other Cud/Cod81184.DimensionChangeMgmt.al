codeunit 81184 "Dimension Change Mgmt"
{
    // Created By Nilesh Gajjar for NAV 2013 R2 Upgrade
    Description = 'T12149';

    trigger OnRun()
    begin
    end;

    var
        DimMgt_gCdu: Codeunit DimensionManagement;


    procedure FillDimSetEntry_gFnc(OldDimSetID_lInt: Integer; var DimSetEntry_vRec: Record "Dimension Set Entry" temporary)
    begin
        if not DimSetEntry_vRec.IsTemporary then
            Error('Dimension Set Entry Table must be define as temporary');

        Clear(DimMgt_gCdu);
        DimSetEntry_vRec.Reset;
        DimMgt_gCdu.GetDimensionSet(DimSetEntry_vRec, OldDimSetID_lInt);
    end;


    procedure UpdateDimSetEntry_gFnc(var DimSetEntry_vRec: Record "Dimension Set Entry" temporary; DimensionCode_iCod: Code[20]; DimensionValue_iCod: Code[20]): Boolean
    var
        DimValue_lRec: Record "Dimension Value";
    begin
        if DimensionValue_iCod <> '' then begin
            DimValue_lRec.Get(DimensionCode_iCod, DimensionValue_iCod);  //Just check for dim value exists

            DimSetEntry_vRec.Reset;
            DimSetEntry_vRec.SetRange("Dimension Code", DimensionCode_iCod);
            if not DimSetEntry_vRec.FindFirst then begin
                DimSetEntry_vRec.Init;
                DimSetEntry_vRec.Validate("Dimension Code", DimensionCode_iCod);
                DimSetEntry_vRec.Validate("Dimension Value Code", DimensionValue_iCod);
                DimSetEntry_vRec.Insert(true);
                exit(true);
            end else begin
                if DimSetEntry_vRec."Dimension Value Code" <> DimensionValue_iCod then begin
                    ;
                    DimSetEntry_vRec.Validate("Dimension Value Code", DimensionValue_iCod);
                    DimSetEntry_vRec.Modify(true);
                    exit(true);
                end;
            end;
        end;
    end;


    procedure GetDimensionSetID_gFnc(var DimSetEntry_vRecTmp: Record "Dimension Set Entry" temporary) DimSetID: Integer
    begin
        DimSetID := DimMgt_gCdu.GetDimensionSetID(DimSetEntry_vRecTmp);
    end;


    procedure UpdGlobalDimFromSetID_gFnc(DimSetID: Integer; var GlobalDimVal1: Code[20]; var GlobalDimVal2: Code[20])
    begin
        DimMgt_gCdu.UpdateGlobalDimFromDimSetID(DimSetID, GlobalDimVal1, GlobalDimVal2);
    end;
}


